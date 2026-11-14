
function bytes = pack12(codes)

    % Initialize empty byte array
    bytes = uint8([]);

    % Number of codes
    n = numel(codes);

    % Process two codes at a time
    i = 1;

    while i <= n

        % First code (12 bits)
        A = codes(i);

        % Byte 1: Upper 8 bits of A
        byte1 = floor(A / 16);

        if i + 1 <= n

            % Second code (12 bits)
            B = codes(i + 1);

            % Byte 2: Lower 4 bits of A + upper 4 bits of B
            byte2 = mod(A, 16) * 16 + floor(B / 256);

            % Byte 3: Lower 8 bits of B
            byte3 = mod(B, 256);

            % Append all three bytes
            bytes = [bytes, uint8(byte1), ...
                            uint8(byte2), ...
                            uint8(byte3)];

        else

            % Odd number of codes:
            % Only the first code remains.

            % Byte 2: Lower 4 bits of A followed by 4 zero bits
            byte2 = mod(A, 16) * 16;

            % Append the final two bytes
            bytes = [bytes, uint8(byte1), uint8(byte2)];

        end

        % Move to the next pair of codes
        i = i + 2;

    end

end
