clc; clear;
pkg load signal;

% 음성 파일 읽기
[x, fs] = audioread('C:\test/Received_Signal.wav');

% -----------------------------------------------------------------------------
% Original Signal의 전체 전력 계산 (1초부터 3초까지)
start_time_original = 1;
end_time_original = 3;
start_index_original = floor(start_time_original * fs) + 1;
end_index_original = floor(end_time_original * fs);
original_signal = x(start_index_original:end_index_original);
original_signal_power = sum(abs(original_signal).^2) / length(original_signal);

% 필터링할 구간 선택 (0초부터 1초까지)
start_time_filtered = 0;
end_time_filtered = 1;
start_index_filtered = floor(start_time_filtered * fs) + 1;
end_index_filtered = floor(end_time_filtered * fs);
segment = x(start_index_filtered:end_index_filtered);

% Original Signal의 잡음 전력 계산 (0초부터 1초까지)
original_noise_power = sum(abs(segment).^2) / length(segment);

% Original Signal의 SNR 계산
original_snr_db = 10 * log10(original_signal_power / original_noise_power);
fprintf('Original Signal-to-Noise Ratio: %.2f dB\n', original_snr_db);
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
% 3 kHz 주파수 성분만 남기기
target_frequency = 3000;
tolerance = 50;
frequencies = (0:length(x)-1)*(fs/length(x));
target_range = frequencies > target_frequency - tolerance & frequencies < target_frequency + tolerance;
X = fft(x);
X(~target_range) = 0;
filtered_signal = ifft(X);
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
% Filtered Signal의 전체 전력 계산 (1초부터 3초까지)
start_time_filtered = 1;
end_time_filtered = 3;
start_index_filtered = floor(start_time_filtered * fs) + 1;
end_index_filtered = floor(end_time_filtered * fs);
filtered_signal_power = sum(abs(filtered_signal(start_index_filtered:end_index_filtered)).^2) / length(filtered_signal(start_index_filtered:end_index_filtered));

% Filtered Signal의 잡음 전력 계산 (0초부터 1초까지)
start_time_filtered_part = 0;
end_time_filtered_part = 1;
start_index_filtered_part = floor(start_time_filtered_part * fs) + 1;
end_index_filtered_part = floor(end_time_filtered_part * fs);
filtered_noise_power_part = sum(abs(filtered_signal(start_index_filtered_part:end_index_filtered_part)).^2) / length(filtered_signal(start_index_filtered_part:end_index_filtered_part));

% Filtered Signal에서 0초에서 1초까지의 전력에서 Original Signal의 잡음 전력을 빼기
power_difference = filtered_signal_power - filtered_noise_power_part;
fprintf('필터링 후 신호전력 - 필터링 후 잡음전력: %f\n', power_difference);

% Filtered Signal의 SNR 계산
filtered_snr_db_part = 10 * log10((filtered_signal_power-filtered_noise_power_part) / filtered_noise_power_part);
fprintf('Filtered Signal-to-Noise Ratio (0-1s): %.2f dB\n', filtered_snr_db_part);

% -----------------------------------------------------------------------------
% 필터링 된 신호를 저장할 파일 경로 및 이름 지정
filtered_signal_file = 'c:\test/Filtered_Signal.wav';
% 필터링 된 신호를 오디오 파일로 저장
audiowrite(filtered_signal_file, filtered_signal, fs);
% -----------------------------------------------------------------------------
