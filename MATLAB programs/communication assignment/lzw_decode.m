
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

    % TODO 1: Output the first code as a single byte
    bytes(end + 1) = uint8(prev);

    for i = 2:numel(codes)

        % Read the current code
        k = codes(i);

        if k < nextCode

            % TODO 2: Expand the existing dictionary code
            seq = expand(k, prefix, suffix);

        else

            % TODO 3: Special LZW case (k == nextCode)
            % Sequence = previous sequence + its first byte
            prevSeq = expand(prev, prefix, suffix);
            seq = [prevSeq, prevSeq(1)];

        end

        % TODO 4: Append the decoded sequence to output
        bytes = [bytes, uint8(seq)];

        % Add a new dictionary entry if space is available
        if nextCode < 4096

            % TODO 5: Store the previous code as the prefix
            prefix(nextCode + 1) = prev;

            % Store the first byte of the current sequence as suffix
            suffix(nextCode + 1) = seq(1);

            % Move to the next available dictionary code
            nextCode = nextCode + 1;

        end

        % Update previous code for the next iteration
        prev = k;

    end
end


% Helper function to expand a dictionary code into its byte sequence
function seq = expand(code, prefix, suffix)

    % If code is a literal byte, return it directly
    if code < 256
        seq = uint8(code);
        return;
    end

    % Temporary storage for the decoded sequence
    seq = uint8([]);

    % Follow prefix links until reaching a literal byte
    while code >= 256

        % MATLAB uses 1-based indexing
        idx = code + 1;

        % Add the suffix byte to the sequence
        seq(end + 1) = uint8(suffix(idx));

        % Move to the prefix code
        code = prefix(idx);

    end

    % Add the final literal byte
    seq(end + 1) = uint8(code);

    % Reverse the sequence to restore original byte order
    seq = fliplr(seq);

end
