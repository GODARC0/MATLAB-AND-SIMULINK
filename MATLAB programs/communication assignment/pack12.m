
function bytes = pack12(codes)

    % Number of input codes
    n = numel(codes);

    %% STEP 1: Preallocate output byte array

    % Two codes require 3 bytes.
    % One remaining code requires 2 bytes.
    totalBytes = 3 * floor(n/2) + 2 * mod(n,2);

    bytes = zeros(1, totalBytes, 'uint8');

    % Output array index
    p = 1;

    %% STEP 2: Process two codes at a time

    i = 1;

    while i <= n

        % First 12-bit code
        A = codes(i);

        % Byte 1: Upper 8 bits of A
        byte1 = floor(A / 16);

        if i + 1 <= n

            % Second 12-bit code
            B = codes(i + 1);

            % Byte 2: Lower 4 bits of A + upper 4 bits of B
            byte2 = mod(A, 16) * 16 + floor(B / 256);

            % Byte 3: Lower 8 bits of B
            byte3 = mod(B, 256);

            %% Write three bytes directly

            bytes(p)     = uint8(byte1);
            bytes(p + 1) = uint8(byte2);
            bytes(p + 2) = uint8(byte3);

            % Move output index forward by 3
            p = p + 3;

        else

            % Odd number of codes: only A remains.

            % Byte 2: Lower 4 bits of A followed by 4 zero bits
            byte2 = mod(A, 16) * 16;

            %% Write final two bytes

            bytes(p)     = uint8(byte1);
            bytes(p + 1) = uint8(byte2);

            % Move output index forward by 2
            p = p + 2;

        end

        % Move to next pair of codes
        i = i + 2;

    end

end
