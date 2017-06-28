function out=simpFFT(d1,d2)
    out=abs(ifft(fft(d1).*fft(d2)));
end