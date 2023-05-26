clear all
close all
clc
filtro = FilterNotch(223,0.1,0.7,0.001);
filtro.Discretization;

filtro.Starting();
filtro.TransferFunctionC
filtro.TransferFunctionD
temp = 1
tempo =0:0.001 :temp;
reference = ones(1,length(tempo))*10;
out = zeros(1,length(reference));
for h = 1:length(reference)
    outx = filtro.Compute(reference(h));
    out(1,h) = outx;
end
figure
plot(tempo,out,'-r')
hold on
opt = stepDataOptions('StepAmplitude',10);
wn = 223;
xci_z=0.1; %aggiustate xci_z e xci_p per rendere il filtro più o meno selettivo
xci_p=0.7;
s=tf('s');
Fs=(s^2+2*xci_z*wn*s+wn^2)/(s^2+2*xci_p*wn*s+wn^2)
Fs_d = c2d(Fs,0.001);
Fs_d.Variable='z^-1'
step(Fs,temp,opt)
step(Fs_d,temp,opt)
legend("filtro","continuo","discreto")
    