function [f] = shifted_rotated_rastrigin(x)
%
% Define a função Shifted Rotated Rastrigin adotada em Zang2014 e em
% Sun2017. Essa função corresponde a função F10 definida em:
% P. N. Suganthan, N. Hansen, J. J. Liang, K. Deb, Y. P. Chen, A.
% Auger, and S. Tiwari, “Problem definitions and evaluation criteria for
% the CEC 2005 special session on real-parameter optimization,” Nanyang
% Tech. Univ., Singapore, Tech. Rep. and IIT Kanpur, India, KanGAL Rep.
% 2005005, May 2005.

% Entrada:
%           x: Vetor 1xn, n no máximo 100
%           f: Avaliação de x

% Domínio das variáves: [-5,5]^n
% Ótimo global: xstar = o, f(xstar) = -330

% Define parâmetros
global initial_flag
initial_flag = 0;
func_num = 10;
x = x(:);
x = x';

%f = benchmark_func_copia(x,func_num);
f = benchmark_func(x,func_num);

% Correção para função assumir fmin = 0
f = f + 330;

clear initial_flag

end


