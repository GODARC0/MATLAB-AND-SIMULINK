
function bytes = lzw_decode(codes)

    % Initialize empty output byte array
    bytes = uint8([]);

    % Handle empty input
    if isempty(codes)
        return;
    end

    % Dictionary arrays (12-bit codes: 0 to 4095)
    prefix = zeros(1, 4096);
    suffix = zeros(1, 4096);

    % First available dictionary code
    nextCode = 256;

    % First code from the encoded input
    prev = codes(1);

    %% STEP 1: Preallocate cell array for decoded sequences

    % Each input code produces one decoded sequence
    out = cell(1, numel(codes));

    % Store the first decoded byte
    out{1} = uint8(prev);

    %% STEP 2: Process remaining codes

    for i = 2:numel(codes)

        % Read current code
        k = codes(i);

        if k < nextCode

            % Existing dictionary entry
            seq = expand(k, prefix, suffix);

        elseif k == nextCode

            % Special LZW case:
            % Previous sequence followed by its first byte
            prevSeq = expand(prev, prefix, suffix);

            seq = [prevSeq, prevSeq(1)];

        else

            % Invalid dictionary code
            error('lzw:invalidCode', ...
                  'Invalid LZW code encountered.');

        end

        %% STEP 3: Store decoded sequence

        % Store sequence in the corresponding cell
        out{i} = uint8(seq);

        %% STEP 4: Update dictionary

        if nextCode < 4096

            % Store previous code as prefix
            prefix(nextCode + 1) = prev;

            % Store first byte of current sequence as suffix
            suffix(nextCode + 1) = seq(1);

            % Increment next available code
            nextCode = nextCode + 1;

        end

        % Update previous code
        prev = k;

    end

    %% STEP 5: Combine all decoded sequences

    % Concatenate cell contents into final byte array
    bytes = [out{:}];

end


%% Helper function: Expand dictionary code

function seq = expand(code, prefix, suffix)

    % Literal byte: return directly
    if code < 256
        seq = uint8(code);
        return;
    end

    % Temporary sequence storage
    seq = uint8([]);

    % Follow prefix links until reaching a literal byte
    while code >= 256

        % MATLAB uses 1-based indexing
        idx = code + 1;

        % Append suffix byte
        seq(end + 1) = uint8(suffix(idx));

        % Move to prefix code
        code = prefix(idx);

    end

    % Append final literal byte
    seq(end + 1) = uint8(code);

    % Reverse to restore original byte order
    seq = fliplr(seq);

end
