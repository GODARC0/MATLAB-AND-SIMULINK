
clc;
clear;

fprintf('===== LZW 12-BIT PACKING TESTS =====\n\n');

%% TEST 1: Even number of codes

codes_even = [65 66 256 258];

packed_even = pack12(codes_even);

unpacked_even = unpack12(packed_even, numel(codes_even));

fprintf('Test 1: Even number of codes\n');

disp('Original codes:');
disp(codes_even);

disp('Packed bytes:');
disp(packed_even);

disp('Unpacked codes:');
disp(unpacked_even);

assert(isequal(codes_even, unpacked_even), ...
       'Even-length test FAILED');

fprintf('PASS: Even-length test\n\n');


%% TEST 2: Odd number of codes

codes_odd = [65 66 256 258 300];

packed_odd = pack12(codes_odd);

unpacked_odd = unpack12(packed_odd, numel(codes_odd));

fprintf('Test 2: Odd number of codes\n');

disp('Original codes:');
disp(codes_odd);

disp('Packed bytes:');
disp(packed_odd);

disp('Unpacked codes:');
disp(unpacked_odd);

assert(isequal(codes_odd, unpacked_odd), ...
       'Odd-length test FAILED');

fprintf('PASS: Odd-length test\n\n');


%% TEST 3: Random code vector (even length)

rng(42);

random_codes_even = randi([0 4095], 1, 100);

packed_random_even = pack12(random_codes_even);

unpacked_random_even = unpack12( ...
    packed_random_even, numel(random_codes_even));

assert(isequal(random_codes_even, unpacked_random_even), ...
       'Random even test FAILED');

fprintf('PASS: Random even-length test\n\n');


%% TEST 4: Random code vector (odd length)

random_codes_odd = randi([0 4095], 1, 101);

packed_random_odd = pack12(random_codes_odd);

unpacked_random_odd = unpack12( ...
    packed_random_odd, numel(random_codes_odd));

assert(isequal(random_codes_odd, unpacked_random_odd), ...
       'Random odd test FAILED');

fprintf('PASS: Random odd-length test\n\n');


%% TEST 5: Boundary values

boundary_codes = [0 4095 4095 0 255];

packed_boundary = pack12(boundary_codes);

unpacked_boundary = unpack12( ...
    packed_boundary, numel(boundary_codes));

assert(isequal(boundary_codes, unpacked_boundary), ...
       'Boundary test FAILED');

fprintf('PASS: Boundary-value test\n\n');


fprintf('===== ALL TESTS PASSED =====\n');
