filtro = FilterFirstOrder(1/800,0.001);
filtro.Discretization();

filtro.Starting
tempo =0:0.001 :(0.1-0.001);
reference = ones(1,100)*5
out = zeros(1,length(reference));
for h = 1:length(reference)
    outx = filtro.Compute(reference(h));
    out(1,h) = outx
end
figure
plot(tempo,out,'-r')
hold on
opt = stepDataOptions('StepAmplitude',5);
s  = tf('s');
Fs = 1/(1+s*(1/800))
Fs_d = c2d(Fs,0.001,'ZOH')
Fs_d.Variable='z^-1'
step(Fs,opt)
step(Fs_d,opt)
legend("filtro","continuo","discreto")
    