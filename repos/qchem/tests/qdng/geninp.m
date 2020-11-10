%
% generate 2D potential and guess WF
%
Nx=256;
x=linspace(-1,1,Nx);
[X,Y] = ndgrid(x,x);

w=0.03; m=18000;
k=m*w;
a=m*w;

pot = 0.5 * k * X.^2 + 0.5 * k * Y.^2;
pot(pot > 0.75) = 0.75;

f = fopen('pot.op','w');
fwrite(f,pot(:),'double');
fclose(f);

wf = zeros(Nx*Nx*2,1);
gauss = exp(-a*X.^2) .* exp(-a*Y.^2);

wf(1:2:end-1) = gauss(:);

f = fopen('guess.wf','w');
fwrite(f,wf(:),'double');
fclose(f);

f = fopen('pot.meta','w');
fprintf(f,'CLASS=OGridPotential\ndims=2\nN0=%d\nN1=%d\nxmin0=%.2f\nxmax0=%2.f\nxmin1=%.2f\nxmax1=%2.f\n',Nx,Nx,min(x),max(x),min(x),max(x));
fclose(f);

f = fopen('guess.meta','w');
fprintf(f,'CLASS=WFGridCartesian\ndims=2\nN0=%d\nN1=%d\nxmin0=%.2f\nxmax0=%2.f\nxmin1=%.2f\nxmax1=%2.f\n',Nx,Nx,min(x),max(x),min(x),max(x));
fclose(f);

