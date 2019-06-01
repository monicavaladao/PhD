********************************************************************************
SQPLAB optimization solver (Version 0.4.4, February 2009, entry point)
  simulator name: "hanging_chain_sqplabsim"
  dimensions:
  . variables (n):                  8
  . inequality constraints (mi):   12
  . equality constraints (me):      5
  required tolerances for optimality:
  . gradient of the Lagrangian      1.00e-06
  . feasibility                     1.00e-06
  . complementarity                 1.00e-06
  counters:
  . max iterations                  1000
  algorithm:
  . quasi-Newton method
  . globalization by Armijo's linesearch
  various input/initial values:
  . infinite bound threshold             Inf
  . |x|_2                           1.20e+00
  . |lm|_2                          3.67e-01 (default: least-squares value)
  . |g|_inf                         3.50e-01
  . |glag|_inf                      3.47e-17
  . |ci^#|_inf                      4.00e-02
  . |ce|_inf                        1.10e-01
  . |complementarity|_inf           1.52e-01
  tunings:
  . printing level                  3

### sqplab_checkoptions: descent ensured by Powell corrections

--------------------------------------------------------------------------------
iter simul  stepsize      cost      |grad Lag|  feasibility  BFGS
   1     1            -4.40000e-01  3.4694e-17  1.10000e-01  0.25
   2     3  1.56e-01  -4.27551e-01  3.9819e-01  9.11133e-02  0.46
   3     4  1.00e+00  -4.53879e-01  4.1311e-01  3.23665e-02  0.22
   4     5  1.00e+00  -4.52539e-01  7.9111e-02  5.60853e-03  0.50
   5     6  1.00e+00  -4.54881e-01  4.0172e-02  2.46483e-04  0.28
   6     7  1.00e+00  -4.55020e-01  1.2849e-03  3.96415e-07  0.10
   7     8  1.00e+00  -4.55020e-01  1.8041e-06  1.39261e-12

### sqplab_armijo: stop on dxmin

            alpha      = 1.00000e+00
            |d|_inf    = 4.14723e-12
            |xp-x|_inf = 4.14724e-12

--------------------------------------------------------------------------------
SQPLAB optimization solver (exit point)
  Status 0: required tolerances are satisfied
  Cost                                    -4.55020e-01
  Optimality conditions:
  . gradient of the Lagrangian (inf norm)  5.70713e-12
  . feasibility                            1.39261e-12
  . complementarity                        0.00000e+00
  Counters:
  . nbr of iterations                      7
  . nbr of simulations( 2)                 7
  . nbr of simulations( 3)                 7
  . nbr of simulations( 4)                 1
********************************************************************************

CPU time = 0.620351 sec

Joint positions (and floor multipliers):
   #j      x         y     mult (floor 1)  mult (floor 2)  mult (floor 3)
    1   0.22164  -0.33298   2.1507329e-01   0.0000000e+00   0.0000000e+00
    2   0.49796  -0.44980   0.0000000e+00   3.8748110e-01   0.0000000e+00
    3   0.67851  -0.27688   0.0000000e+00   0.0000000e+00   0.0000000e+00
    4   0.79192  -0.44162   0.0000000e+00   0.0000000e+00   4.4329513e-01

VARIABLES x
 2.21636875083904e-01  4.97960085512275e-01  6.78511962184494e-01  7.91917789209899e-01 -3.32982125050342e-01
-4.49796008551228e-01 -2.76876895003477e-01 -4.41616442158020e-01 

INEQUALITY CONSTRAINTS
i      lower bound               ci                upper bound           multiplier
1                  -Inf  0.00000000000000e+00  0.00000000000000e+00  2.15073290886154e-01
2                  -Inf -4.89800427561374e-02  0.00000000000000e+00  0.00000000000000e+00
3                  -Inf -3.30230282311297e-01  0.00000000000000e+00  0.00000000000000e+00
4                  -Inf -2.33534231367919e-01  0.00000000000000e+00  0.00000000000000e+00
5                  -Inf -8.91815624580480e-02  0.00000000000000e+00  0.00000000000000e+00
6                  -Inf  0.00000000000000e+00  0.00000000000000e+00  3.87481104339136e-01
7                  -Inf -1.90974301219108e-01  0.00000000000000e+00  0.00000000000000e+00
8                  -Inf -3.75753367629697e-02  0.00000000000000e+00  0.00000000000000e+00
9                  -Inf -2.22690499932877e-01  0.00000000000000e+00  0.00000000000000e+00
10                  -Inf -5.06119743463174e-02  0.00000000000000e+00  0.00000000000000e+00
11                  -Inf -1.87420712563794e-01  0.00000000000000e+00  0.00000000000000e+00
12                  -Inf  0.00000000000000e+00  0.00000000000000e+00  4.43295128819014e-01

EQUALITY CONSTRAINTS
i          ce                multiplier
1  0.00000000000000e+00  1.67945482745493e-01 
2  2.77555756156289e-17 -9.87940001231511e-02 
3  1.39260825093857e-12 -2.58502605239472e-01 
4  1.39257355646905e-12 -4.11558486231295e-01 
5  2.77555756156289e-17 -1.12629407840850e-02 
