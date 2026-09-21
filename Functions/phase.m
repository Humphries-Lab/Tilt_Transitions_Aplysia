function [thetamax,max_rotP,Max_rot_3,theta_max_3]=phase(x,Fs,do_plot)
y = fft(x);
z = fftshift(y);
ly = length(y);
f = (-ly/2:ly/2-1)*Fs/ly;


[~,i]=max(abs(z));
[~,idx_sort]=sort(abs(z),'descend');
maxf=abs(f(i));

thetamax=angle(z(i));
max_rotP=1/maxf;

Max_rot_3=1./abs(f(idx_sort(1:3)));
theta_max_3=angle(z(idx_sort(1:3)));


if do_plot
    subplot(3,1,1)
    time=(1:numel(x))/Fs;
    plot(time,x)
    
    subplot(3,1,2)
    stem(f,abs(z))
    xlabel 'Frequency (Hz)'
    ylabel '|y|'
    grid
    
    
    tol = 1e-6;
    z(abs(z) < tol) = 0;
    theta = angle(z);
    
    subplot(3,1,3)
    stem(f,theta/pi)
    xlabel 'Frequency (Hz)'
    ylabel 'Phase / \pi'
    grid
end
end
