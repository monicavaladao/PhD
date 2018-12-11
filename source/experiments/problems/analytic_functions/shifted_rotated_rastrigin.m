function [f] = shifted_rotated_rastrigin(x)
%
% Define a fun��o Shifted Rotated Rastrigin adotada em Zang2014 e em
% Sun2017. Essa fun��o corresponde a fun��o F10 definida em:
% P. N. Suganthan, N. Hansen, J. J. Liang, K. Deb, Y. P. Chen, A.
% Auger, and S. Tiwari, �Problem definitions and evaluation criteria for
% the CEC 2005 special session on real-parameter optimization,� Nanyang
% Tech. Univ., Singapore, Tech. Rep. and IIT Kanpur, India, KanGAL Rep.
% 2005005, May 2005.

% Entrada:
%           x: Vetor 1xn, n no m�ximo 100
%           f: Avalia��o de x

% Dom�nio das vari�ves: [-5,5]^n
% �timo global: xstar = o, f(xstar) = -330

% Define par�metros
global initial_flag
initial_flag = 0;
func_num = 10;
x = x(:);
x = x';

%f = benchmark_func_copia(x,func_num);
f = benchmark_func(x,func_num);

% Corre��o para fun��o assumir fmin = 0
f = f + 330;

clear initial_flag

end


