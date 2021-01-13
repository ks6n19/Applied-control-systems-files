close all;
clear;
clc;

load x-axis_7th_order_model.mat;

T = 2;
Ts = 0.01;

N = 100;
w = 1e-2;

t = 0:Ts:T;
t(1) = [];

% construct reference
ref = t'*0;
ref(find(t<=1)) = t(find(t<=1))*0.035;
ref(find(t>1)) = 0.07 - t(find(t>1))*0.035;

% discretise system
sysd = ss(c2d(sysc,Ts));

% create G matrix
g = impulse(sysd,T);
g(1) = [];
G = toeplitz(g,g*0);

% ILC weights
R = eye(size(G)) * 0.01;
Q = eye(size(G));

% create vectors to store results 
u = 0*t'; % start from zero. Could start from ref, but results worse
%u = ref;
e = ref - G*u;
enorm0 = norm(e)
enorm = zeros(N,1);
gamma = zeros(N,1);

% if you used a fixed gamma, then the fastest cnvergence would require
% minimising ||I - gamma G'*G||^2 wrt gamma. This has the solution below
gamopt = 1/norm(G)^2;

for i=1:N
    
    gamma(i) = norm(G'*e)^2/(w + norm(G*G'*e)^2);
%     gamma(i) = gamopt; % if you wanted to use a fixed gamma
    u = u + gamma(i) * G'*e;
    
%     u  = u + inv(R+G'*Q*G)*G'* Q*e; % if you wanted NOILC
    
    e = ref - G*u;
    
    enorm(i) = norm(e);
end

final_enorm = norm(e)

figure
plot(1:N,enorm); xlabel('Trial, k'); ylabel('Error Norm');
figure
semilogy(1:N,enorm); xlabel('Trial, k'); ylabel('Error Norm');
figure
plot(1:N,gamma); xlabel('Trial, k'); ylabel('gamma');
figure
plot(t,u); xlabel('Time (s)'); ylabel('u');
figure
plot(t,e); xlabel('Time (s)'); ylabel('e');

