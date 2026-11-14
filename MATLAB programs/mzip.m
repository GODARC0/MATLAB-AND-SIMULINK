
function mzip(option, infile, outfile)
% MZIP - Simple LZW-based file compression utility
%
% Usage:
%   mzip('c', 'input.txt', 'output.mzip')
%
% Options:
%   'c' = Compress
%   'd' = Decompress (to be implemented)
%   'i' = Information (to be implemented)
%
% File format:
%   4 bytes : Original file size (uint32, big-endian)
%   4 bytes : Number of LZW codes (uint32, big-endian)
%   Remaining bytes : Packed 12-bit LZW codes

    %% STEP 1: Validate option

    if ~ischar(option) || ~isscalar(option) || ...
            ~ismember(option, ['c', 'd', 'i'])
        error('mzip:invalidOption', ...
              'Invalid option. Use c, d, or i.');
    end

    %% STEP 2: Check input arguments

    if nargin < 2
        error('mzip:missingInput', ...
              'Please provide an input filename.');
    end

    if option == 'c' && nargin < 3
        error('mzip:missingOutput', ...
              'Please provide an output filename.');
    end

    %% STEP 3: Execute selected operation

    switch option

        case 'c'

            %% COMPRESSION

            fprintf('Starting compression...\n');

            % Open input file in read mode
            fid = fopen(infile, 'r');

            if fid < 0
                error('mzip:fileNotFound', ...
                      'Cannot open file: %s', infile);
            end

            % Read the entire file as uint8 bytes
            data = fread(fid, Inf, 'uint8=>uint8')';

            % Close input file
            fclose(fid);

            % Check whether original size fits in uint32
            if numel(data) > double(intmax('uint32'))
                error('mzip:fileTooLarge', ...
                      'Input file exceeds uint32 size limit.');
            end

            %% STEP 4: LZW ENCODING

            fprintf('Encoding data using LZW...\n');

            codes = lzw_encode(data);

            %% STEP 5: Pack 12-bit codes into bytes

            fprintf('Packing 12-bit codes...\n');

            packed = pack12(codes);

            %% STEP 6: Prepare file header

            originalSize = uint32(numel(data));
            numCodes = uint32(numel(codes));

            %% STEP 7: Create output file

            fid = fopen(outfile, 'w', 'ieee-be');

            if fid < 0
                error('mzip:outputError', ...
                      'Cannot create output file: %s', outfile);
            end

            % Ensure output file is closed if an error occurs
            outputCleanup = onCleanup(@() fclose(fid));

            %% STEP 8: Write the 8-byte header

            % First 4 bytes: Original file size
            fwrite(fid, originalSize, 'uint32');

            % Next 4 bytes: Number of LZW codes
            fwrite(fid, numCodes, 'uint32');

            %% STEP 9: Write packed compressed data

            fwrite(fid, packed, 'uint8');

            % Close output file
            clear outputCleanup;

            %% STEP 10: Display compression information

            fprintf('\nCompression completed!\n');

            fprintf('Original size : %d bytes\n', originalSize);
            fprintf('LZW codes     : %d\n', numCodes);
            fprintf('Packed size   : %d bytes\n', numel(packed));
            fprintf('Output file   : %s\n', outfile);

        case 'd'

            error('mzip:notImplemented', ...
                  'Decompression is not implemented yet.');

        case 'i'

            error('mzip:notImplemented', ...
                  'Information mode is not implemented yet.');

    end

end
