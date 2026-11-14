
clc;
clear;

fprintf('========== MZIP ROUND-TRIP TEST ==========\n\n');

%% TEST 1: Normal text file

infile = 'sample.txt';
compressedFile = 'sample.mzip';
restoredFile = 'restored.txt';

% Compress
mzip('c', infile, compressedFile);

% Display compression information
mzip('i', compressedFile);

% Decompress
mzip('d', compressedFile, restoredFile);

% Read original and reconstructed files
fid = fopen(infile, 'rb');
a = fread(fid, Inf, 'uint8=>uint8');
fclose(fid);

fid = fopen(restoredFile, 'rb');
b = fread(fid, Inf, 'uint8=>uint8');
fclose(fid);

% Byte-for-byte comparison
assert(isequal(a, b), ...
       'Round-trip test FAILED: Files are different.');

fprintf('\nPASS: Text file round-trip successful!\n');


%% TEST 2: Empty file

emptyFile = 'empty.txt';
emptyCompressed = 'empty.mzip';
emptyRestored = 'empty_restored.txt';

% Create empty file
fid = fopen(emptyFile, 'wb');
fclose(fid);

% Compress and decompress
mzip('c', emptyFile, emptyCompressed);
mzip('d', emptyCompressed, emptyRestored);

% Verify reconstructed file
info = dir(emptyRestored);

assert(~isempty(info) && info.bytes == 0, ...
       'Empty file test FAILED.');

fprintf('PASS: Empty file round-trip successful!\n');


%% FINAL RESULT

fprintf('\n==========================================\n');
fprintf('ALL ROUND-TRIP TESTS PASSED!\n');
fprintf('==========================================\n');
