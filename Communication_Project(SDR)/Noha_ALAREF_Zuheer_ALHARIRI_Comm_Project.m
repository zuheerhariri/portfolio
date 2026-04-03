% Parameters
N = 1e5;                     % Number of bits
Eb = 1;                      % Assume Eb = 1
EbN0_dB = 0:10;              % Eb/N0 values in dB
EbN0 = 10.^(EbN0_dB/10);     % Linear scale
BER = zeros(size(EbN0_dB));
SNR_dB = zeros(size(EbN0_dB));
P_tx = zeros(size(EbN0_dB));
P_rx = zeros(size(EbN0_dB));
P_noise = zeros(size(EbN0_dB)); % Noise power

% Transmitter
bits = randi([0 1], 1, N);       
symbols = 2*bits - 1;            

% Save one sample for plot
index_to_plot = 4;
EbN0_val = EbN0(index_to_plot);
noise_std_plot = sqrt(1/(2*EbN0_val));
noise_plot = noise_std_plot * randn(1, N);
received_plot = symbols + noise_plot;

% Simulation
for i = 1:length(EbN0)
    No = Eb / EbN0(i);                         
    noise_std = sqrt(No/2);                   
    noise = noise_std * randn(1, N);          
    received = symbols + noise;               
    decoded_bits = received > 0;              
    BER(i) = sum(bits ~= decoded_bits)/N;

    % Power Calculations
    P_tx(i) = mean(symbols.^2);               
    P_noise(i) = mean(noise.^2);              
    P_rx(i) = mean(received.^2);              

    % SNR Calculation
    SNR_linear = P_tx(i) / P_noise(i);        
    SNR_dB(i) = 10*log10(SNR_linear);         
end

% Theoretical BER
BER_theory = qfunc(sqrt(2*EbN0));

% --- Plots ---

% 1. BER Plot
figure;
semilogy(EbN0_dB, BER, 'o-', EbN0_dB, BER_theory, 'r--');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate (BER)');
legend('Simulated', 'Theoretical');
title('BPSK over AWGN');

% 2. Transmitted vs Received Symbols
figure;
subplot(2,1,1);
stem(symbols(1:50), 'filled');
title('Transmitted BPSK Symbols (First 50 bits)');
ylim([-1.5 1.5]);
xlabel('Bit Index'); ylabel('Amplitude');

subplot(2,1,2);
stem(received_plot(1:50), 'filled');
title(['Received Symbols with Noise (Eb/N0 = ', num2str(EbN0_dB(index_to_plot)), ' dB)']);
ylim([-3 3]);
xlabel('Bit Index'); ylabel('Amplitude');

% 3. SNR vs BER Plot
figure;
semilogy(SNR_dB, BER, 'bo-');
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs Actual SNR for BPSK');

% 4. Power Plot: Tx, Rx, Noise
figure;
plot(EbN0_dB, P_tx, 'g-o', EbN0_dB, P_rx, 'm-s', EbN0_dB, P_noise, 'b-^');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Average Power');
legend('Transmitted Power', 'Received Power', 'Noise Power');
title('Average Power of Transmitted, Received, and Noise Signals');

% 5. Ideal BPSK Constellation (No Noise)
bpsk_symbols = [-1, 1];  % BPSK constellation points

figure;
plot(real(bpsk_symbols), imag(bpsk_symbols), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
grid on;
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
title('Ideal BPSK Constellation Diagram');
axis equal;
xlim([-2 2]); ylim([-2 2]);

% 6. Constellation Plot
% Use the same received symbols from a mid-level Eb/N0 (e.g., 3 dB)
num_points = 1000; % Plot a subset for clarity
received_symbols_constellation = symbols(1:num_points) + ...
                                 noise_std_plot * randn(1, num_points);

figure;
plot(real(received_symbols_constellation), imag(received_symbols_constellation), 'bo');
grid on;
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
title(['BPSK Constellation Diagram (Eb/N0 = ', num2str(EbN0_dB(index_to_plot)), ' dB)']);
axis equal;
xlim([-3 3]); ylim([-3 3]);

% 7. Non-Ideal (Noisy) BPSK Constellation (No Decision Boundaries)
num_points = 1000;  % Subset of symbols for clarity
noise_std_noisy = sqrt(1 / (2 * EbN0(index_to_plot))); 
noisy_rx = symbols(1:num_points) + noise_std_noisy * randn(1, num_points);

figure;
plot(real(noisy_rx), imag(noisy_rx), 'bo', 'MarkerSize', 4);
hold on;
plot(bpsk_symbols, [0 0], 'ro', 'MarkerSize', 10, 'LineWidth', 2);  % Ideal points
hold off;

grid on;
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
title(['Noisy BPSK Constellation (Eb/N0 = ', num2str(EbN0_dB(index_to_plot)), ' dB)']);
axis equal;
xlim([-3 3]); ylim([-1 1]);


% 8. Histogram
histogram(real(received), 50);
title('Histogram of Received Symbols');


% 9. BPSK Constellation with Bit Decision Boundary
bpsk_symbols = [-1, 1];  % Ideal BPSK constellation points

figure;
hold on;
plot(real(bpsk_symbols), imag(bpsk_symbols), 'ro', 'MarkerSize', 10, 'LineWidth', 2);

% Add decision boundary (I = 0)
xline(0, '--k', 'LineWidth', 1.5);
text(-1, 0.2, 'bit = 0', 'HorizontalAlignment', 'center', 'FontSize', 12);
text(1, 0.2, 'bit = 1', 'HorizontalAlignment', 'center', 'FontSize', 12);

% Axis formatting
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
title('Ideal BPSK Constellation with Bit Decisions');
axis equal;
xlim([-2 2]); ylim([-1 1]);
grid on;
hold off;

