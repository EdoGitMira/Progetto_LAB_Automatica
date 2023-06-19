clear all
close all
clc
x=0:0.0001:1-0.001;
y = zeros(length(x),1);
for i = 1:1:length(x)
    y(i) = (1+x(i))/(1-x(i));
end

plot(x,y)