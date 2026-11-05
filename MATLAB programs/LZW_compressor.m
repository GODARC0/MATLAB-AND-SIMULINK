
function dictionary = LZW_compressor()

    % Create an empty dictionary
    dictionary = containers.Map('KeyType', 'char', ...
                                'ValueType', 'double');

    % Initialize dictionary with 256 byte values
    for code = 0:255

        character = char(code);

        dictionary(character) = code;

    end

end
