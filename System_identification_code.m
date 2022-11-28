s = tf('s');
Greal = 5*(s+1)/(s^2+4*s+5)*exp(-0.1*s);

dt = 0.01;
t = 0:dt:5;

%Building Step input
u = ones(length(t), 1);
u(1:1/dt)= 0;

%Simulate step response
yreal = lsim(Greal, u, t);

plot(t, [u, yreal], 'Linewidth', 4)
axis([0 5 0 1.4]);

%Fit data to a transfer function with an unknown delay term
data = iddata(yreal, u, dt);%Encapsulates Input/Output measurements of a real system to be used later 
Gtest = tfest(data, 2, 0, NaN);

%Validate model (find out how good it is)
opt = compareOptions;
opt.InitialCondition = 'z';
compare(data, Gtest, opt);
set(findall(gca, 'Type', 'Line'),'Linewidth', 4);
grid on

%Alternative means of estimating system dynamics (transfer function)
%Seperate delay term from linear term by identifying and removing it from
%system response
delay_samples = delayest(data);

yreal_no_delay = yreal(delay_samples+1:end);
data_offset = iddata(yreal_no_delay, u(1:end-delay_samples), dt);
%Fit data to a state space of unknown order
Gss = ssest(data_offset, 1:10)%The 1:10 tells MATLAB to do trial an error in fitting the data to state-space models that are between 1 to 10 in terms of order
%Convert to tf and add in the delay term
Gest = tf(Gss)*exp(-delay_samples*dt*s);

%Validate model (find out how good it is)
opt = compareOptions;
opt.InitialCondition = 'z';
compare(data, Gest, opt);
set(findall(gca, 'Type', 'Line'),'Linewidth', 4);
grid on

