
function codes = unpack12(bytes, ncodes)

    % Initialize output array
    codes = zeros(1, ncodes);

    % Byte position
    j = 1;

    % Code position
    i = 1;

    while i <= ncodes

        % Read first byte
        byte1 = double(bytes(j));

        % Read second byte
        byte2 = double(bytes(j + 1));

        % Reconstruct first 12-bit code
        A = byte1 * 16 + floor(byte2 / 16);

        codes(i) = A;

        if i + 1 <= ncodes

            % Read third byte
            byte3 = double(bytes(j + 2));

            % Reconstruct second 12-bit code
            B = mod(byte2, 16) * 256 + byte3;

            codes(i + 1) = B;

            % Three bytes consumed
            j = j + 3;

        else

            % Odd number of codes:
            % Only two bytes consumed
            j = j + 2;

        end

        % Move to the next pair
        i = i + 2;

    end

end
