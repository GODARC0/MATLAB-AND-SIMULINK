
function mzip(option, infile, outfile)
% MZIP - LZW-based file compression utility
%
% Usage:
%   mzip('c', 'input.txt', 'output.mzip')
%   mzip('d', 'input.mzip', 'restored.txt')
%   mzip('i', 'input.mzip')
%
% Options:
%   c = Compress
%   d = Decompress
%   i = Display information
%
% File format:
%   4 bytes : Original file size (uint32, big-endian)
%   4 bytes : Number of LZW codes (uint32, big-endian)
%   Remaining bytes : Packed 12-bit LZW codes

    %% STEP 1: Validate option

    if ~(ischar(option) || (isstring(option) && isscalar(option)))
        error('mzip:invalidOption', ...
              'Option must be c, d, or i.');
    end

    option = char(option);

    if ~isscalar(option) || ~ismember(option, ['c','d','i'])
        error('mzip:invalidOption', ...
              'Invalid option. Use c, d, or i.');
    end

    %% STEP 2: Validate input filename

    if nargin < 2 || ...
       ~(ischar(infile) || (isstring(infile) && isscalar(infile)))

        error('mzip:invalidInput', ...
              'A valid input filename is required.');
    end

    infile = char(infile);

    if isempty(infile)
        error('mzip:invalidInput', ...
              'Input filename cannot be empty.');
    end

    %% STEP 3: Validate output filename for c and d

    if option == 'c' || option == 'd'

        if nargin < 3 || ...
           ~(ischar(outfile) || ...
             (isstring(outfile) && isscalar(outfile)))

            error('mzip:missingOutput', ...
                  'A valid output filename is required.');
        end

        outfile = char(outfile);

        if isempty(outfile)
            error('mzip:missingOutput', ...
                  'Output filename cannot be empty.');
        end

    end

    %% STEP 4: Execute selected operation

    switch option

        % =========================================================
        % COMPRESSION
        % =========================================================

        case 'c'

            fprintf('Starting compression...\n');

            % Open original file in binary read mode
            fid = fopen(infile, 'rb');

            if fid < 0
                error('mzip:fileNotFound', ...
                      'Cannot open file: %s', infile);
            end

            inputCleanup = onCleanup(@() fclose(fid));

            % Read original file as uint8 bytes
            data = fread(fid, Inf, 'uint8=>uint8')';

            % Close input file
            clear inputCleanup;

            % Check original file size
            if numel(data) > double(intmax('uint32'))
                error('mzip:fileTooLarge', ...
                      'Input file exceeds uint32 size limit.');
            end

            %% LZW Encoding

            fprintf('Encoding data using LZW...\n');

            codes = lzw_encode(data);

            %% Pack 12-bit codes

            fprintf('Packing 12-bit codes...\n');

            packed = pack12(codes);

            %% Prepare header

            originalSize = uint32(numel(data));
            numCodes = uint32(numel(codes));

            %% Create output file

            fid = fopen(outfile, 'wb', 'ieee-be');

            if fid < 0
                error('mzip:outputError', ...
                      'Cannot create output file: %s', outfile);
            end

            outputCleanup = onCleanup(@() fclose(fid));

            %% Write 8-byte header

            % First 4 bytes: Original file size
            fwrite(fid, originalSize, 'uint32');

            % Next 4 bytes: Number of LZW codes
            fwrite(fid, numCodes, 'uint32');

            %% Write packed compressed data

            fwrite(fid, packed, 'uint8');

            % Close output file
            clear outputCleanup;

            %% Display compression results

            fprintf('\nCompression completed!\n');

            fprintf('Original size : %d bytes\n', originalSize);
            fprintf('LZW codes     : %d\n', numCodes);
            fprintf('Packed size   : %d bytes\n', numel(packed));
            fprintf('Output file   : %s\n', outfile);


        % =========================================================
        % DECOMPRESSION
        % =========================================================

        case 'd'

            fprintf('Starting decompression...\n');

            % Open compressed file in binary read mode
            fid = fopen(infile, 'rb', 'ieee-be');

            if fid < 0
                error('mzip:fileNotFound', ...
                      'Cannot open file: %s', infile);
            end

            inputCleanup = onCleanup(@() fclose(fid));

            %% Read the 8-byte header

            % Read first 4 bytes: Original file size
            originalSize = fread(fid, 1, 'uint32=>uint32');

            % Read next 4 bytes: Number of LZW codes
            numCodes = fread(fid, 1, 'uint32=>uint32');

            % Validate header
            if isempty(originalSize) || isempty(numCodes)
                error('mzip:invalidFile', ...
                      'Not a valid mzip file.');
            end

            %% Read packed data

            packed = fread(fid, Inf, 'uint8=>uint8')';

            % Close compressed file
            clear inputCleanup;

            %% Validate packed data length

            expectedBytes = 3 * floor(double(numCodes)/2) ...
                          + 2 * mod(double(numCodes), 2);

            if numel(packed) ~= expectedBytes
                error('mzip:corruptFile', ...
                      'Corrupt file: packed data length mismatch.');
            end

            %% Unpack 12-bit codes

            fprintf('Unpacking 12-bit codes...\n');

            codes = unpack12(packed, double(numCodes));

            %% LZW Decoding

            fprintf('Decoding LZW data...\n');

            data = lzw_decode(codes);

            %% Verify reconstructed size

            if numel(data) ~= double(originalSize)
                error('mzip:corruptFile', ...
                      'Corrupt file: size mismatch.');
            end

            %% Write decompressed file

            fid = fopen(outfile, 'wb');

            if fid < 0
                error('mzip:outputError', ...
                      'Cannot create output file: %s', outfile);
            end

            outputCleanup = onCleanup(@() fclose(fid));

            fwrite(fid, data, 'uint8');

            clear outputCleanup;

            %% Display decompression results

            fprintf('\nDecompression completed!\n');

            fprintf('Original size : %d bytes\n', originalSize);
            fprintf('Decoded codes : %d\n', numCodes);
            fprintf('Output size   : %d bytes\n', numel(data));
            fprintf('Output file   : %s\n', outfile);


        % =========================================================
        % INFORMATION
        % =========================================================

        case 'i'

            fprintf('Reading file information...\n');

            % Get complete compressed file size
            fileInfo = dir(infile);

            if isempty(fileInfo) || fileInfo.isdir
                error('mzip:fileNotFound', ...
                      'Cannot open file: %s', infile);
            end

            compressedSize = fileInfo.bytes;

            % Open compressed file
            fid = fopen(infile, 'rb', 'ieee-be');

            if fid < 0
                error('mzip:fileNotFound', ...
                      'Cannot open file: %s', infile);
            end

            inputCleanup = onCleanup(@() fclose(fid));

            %% Read only the 8-byte header

            originalSize = fread(fid, 1, 'uint32=>uint32');
            numCodes = fread(fid, 1, 'uint32=>uint32');

            clear inputCleanup;

            % Validate header
            if isempty(originalSize) || isempty(numCodes)
                error('mzip:invalidFile', ...
                      'Not a valid mzip file.');
            end

            %% Calculate compression statistics

            originalSize = double(originalSize);
            compressedSize = double(compressedSize);

            if originalSize > 0

                % Compression ratio
                ratio = originalSize / compressedSize;

                % Compressed bits per original input byte
                bitsPerByte = 8 * compressedSize / originalSize;

            else

                % Avoid division by zero
                ratio = NaN;
                bitsPerByte = NaN;

            end

            %% Display information

            fprintf('\n===== MZIP FILE INFORMATION =====\n');

            fprintf('Original size   : %.0f bytes\n', originalSize);
            fprintf('Compressed size : %.0f bytes\n', compressedSize);
            fprintf('Number of codes : %d\n', numCodes);

            if originalSize > 0
                fprintf('Compression ratio: %.4f\n', ratio);
                fprintf('Bits per input byte: %.4f\n', bitsPerByte);
            else
                fprintf('Compression ratio: N/A (empty file)\n');
                fprintf('Bits per input byte: N/A (empty file)\n');
            end

            fprintf('=================================\n');

    end

end
