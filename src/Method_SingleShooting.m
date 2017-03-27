%--------------------------------------------------------------------------
% Method_SingleShooting.m
% Attempt to solve the Bryson-Denham problem using a single shooting method
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% Primary Contributor: Daniel R. Herber, Graduate Student, University of 
% Illinois at Urbana-Champaign
% https://github.com/danielrherber/optimal-control-direct-method-examples
%--------------------------------------------------------------------------
function Method_SingleShooting
    % problem parameters
    p.ns = 2; p.nu = 1; % number of states and controls
    p.t0 = 0; p.tf = 1; % time horizon
    p.y0 = 0; p.yf = 0; p.v0 = 1; p.vf = -1; % boundary conditions
    p.l = 1/9;
    % shooting parameters
    p.nt = 10; % number of node points
%     p.nt = 50; % number of node points
    p.t = linspace(p.t0,p.tf,p.nt)'; % time horizon
    % discretized variable indices in x = [u];
    p.ui = 1:p.nt;
    x0 = zeros(p.nt*(p.nu),1); % initial guess (all zeros)
    options = optimoptions(@fmincon,'display','iter','MaxFunctionEvaluations',1e5); % option
    % solve the problem
    x = fmincon(@(x) objective(x,p),x0,[],[],[],[],[],[],@(x) constraints(x,p),options);
    % obtain the optimal solution
    p.u = x(p.ui); % extract
    [~,Y] = ode45(@(t,y) derivative(t,y,p),p.t,[p.y0,p.v0]); % simulation
    y = Y(:,1); v = Y(:,2); % extract states
    % plots
    Plots(y,v,p.u,p,'Single Shooting')
end
% objective function
function f = objective(x,p)
    u = x(p.ui); % extract
    L = u.^2/2; % integrand
    f = trapz(p.t,L); % calculate objective
end
% constraint function
function [c,ceq] = constraints(x,p)
    p.u = x(p.ui); % extract
    [~,Y] = ode45(@(t,y) derivative(t,y,p),p.t,[p.y0,p.v0]); % simulation
    y = Y(:,1); v = Y(:,2); % extract states
    ceq1 = y(end) - p.yf; % final state conditions
    ceq2 = v(end) - p.vf;
    c1 = y - p.l; % path constraints
    % combine constraints
    c = c1; ceq = [ceq1;ceq2];
end
% derivative function
function dydt = derivative(t,y,p)
    dydt(1,1) = y(2); % v
    dydt(2,1) = interp1(p.t,p.u,t); % u
end