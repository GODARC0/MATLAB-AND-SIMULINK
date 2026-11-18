
function codes = lzw_encode(bytes)

    % Handle empty input
    if isempty(bytes)
        codes = [];
        return;
    end

    %% STEP 1: Initialize dictionary lookup table

    % Create a zero-filled lookup table.
    % Each (w,c) pair gets a unique index.
    % Zero means that the sequence is not present.
    tbl = zeros(1, 4096 * 256);

    % Preallocate output array to avoid repeated memory allocation.
    % Maximum possible number of output codes is numel(bytes).
    codes = zeros(1, numel(bytes));

    % Counter for the number of output codes
    n = 0;

    %% STEP 2: Initialize dictionary parameters

    % Codes 0 to 255 represent individual bytes.
    % New dictionary entries start from 256.
    nextCode = 256;

    % Initialize w with the first input byte
    w = double(bytes(1));

    %% STEP 3: Process remaining input bytes

    for i = 2:numel(bytes)

        % Get current byte as double
        c = double(bytes(i));

        % Calculate unique lookup index for (w,c)
        % MATLAB arrays use 1-based indexing.
        idx = w * 256 + c + 1;

        %% STEP 4: Check whether sequence exists

        if tbl(idx) ~= 0

            % Sequence exists.
            % Extend current sequence using its dictionary code.
            w = tbl(idx);

        else

            % Sequence does not exist.

            % Output the code for current sequence
            n = n + 1;
            codes(n) = w;

            % Add new sequence only if dictionary has space
            if nextCode < 4096

                % Store the new dictionary code
                tbl(idx) = nextCode;

                % Increment next available code
                nextCode = nextCode + 1;

            end

            % Start a new sequence with current byte
            w = c;

        end

    end

    %% STEP 5: Output the final remaining sequence

    n = n + 1;
    codes(n) = w;

    %% STEP 6: Remove unused preallocated positions

    codes = codes(1:n);

end
