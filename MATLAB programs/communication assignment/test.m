clc;
clear;

% Initialize dictionary
dictionary = LZW_compressor();

% Test character lookup
disp(dictionary('A'));
disp(dictionary('B'));

% Check whether sequences exist
disp(isKey(dictionary, 'A'));
disp(isKey(dictionary, 'AB'));

% Check dictionary size
disp(dictionary.Count);