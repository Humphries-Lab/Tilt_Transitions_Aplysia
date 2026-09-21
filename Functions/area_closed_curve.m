function A=area_closed_curve(x,y)
N=numel(x);
I=zeros(N,1);
for i=1:N-1
    I(i)=(y(i+1)+y(i))*(x(i+1)-x(i))/2;
end
I(N)=(y(1)+y(N))*(x(1)-x(N))/2;
A=abs(sum(I));
end