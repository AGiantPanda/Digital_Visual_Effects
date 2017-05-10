function param = buildModPoissonParam( s1, s2 )

if( nargin == 1 )
 s = s1;
else
 s = [s1 s2];
end

K=zeros(s(1)*2,s(2)*2);
K(1,1)=4;
K(1,2)=-1;
K(2,1)=-1;
K(s(1)*2,1)=-1;
K(1,s(2)*2)=-1;
param = fft2(K);
param = real(param(1:s(1),1:s(2)));