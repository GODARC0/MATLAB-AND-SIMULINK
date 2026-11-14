
function codes = lzw_encode(bytes)
    
    codes = [];

    % Handle empty input
    if isempty(bytes)
        return;                      % Empty file -> no codes
    end

    % TODO 1: Create an empty Map (numeric keys, numeric values)
    % Keys represent sequences of bytes.
    % Values represent their corresponding LZW codes.
    dict = containers.Map('KeyType', 'double', ...
                          'ValueType', 'double');

    % TODO 2: Initialize next available code
    % Codes 0 to 255 are reserved for individual bytes.
    nextCode = 256;

    % TODO 3: Initialize w with the first byte
    w = double(bytes(1));

    for i = 2:numel(bytes)

        % TODO 4: Convert current byte to double
        c = double(bytes(i));

        % TODO 5: Generate a unique key for sequence (w, c)
        key = w * 256 + c;

        % TODO 6: Check whether the sequence exists in the dictionary
        if isKey(dict, key)

            % If sequence exists, extend the current sequence
            % using its dictionary code
            w = dict(key);

        else

            codes(end + 1) = w;        % always output w
            if nextCode < 4096         % add entry only if space
                dict(key) = nextCode;
                nextCode = nextCode + 1;
            end
            w = c;                     % always restart from c
        
        end
    end
    % TODO 7: Output the final remaining sequence
    codes(end + 1) = w;

end
