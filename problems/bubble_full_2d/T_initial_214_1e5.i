[Mesh]
  type = FileMesh
  file = phi_initial_1e5_0003_mesh.xdr
  dim = 2
[]

[Variables]
  [./T]
  [../]
[]

[AuxVariables]
  [./u]
  [../]
  [./phi]
  [../]
[]

[Kernels]
  [./heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
[]

[AuxKernels]
  [./phi_aux]
    type = SolutionAux
    variable = phi
    solution = phi_initial
  [../]
[]

[BCs]
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = bottom
    value = 259.27
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = top
    value = 258.2
  [../]
[]

[UserObjects]
  [./phi_initial]
    type = SolutionUserObject
    mesh = phi_initial_1e5_0003_mesh.xdr
    es = phi_initial_1e5_0003.xdr
    nodal_variables = phi
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Steady
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = '500 hypre boomeramg'
[]

[Outputs]
  exodus = true
  console = false
  [./console]
    type = Console
    perf_log = true
    nonlinear_residuals = true
    linear_residuals = true
  [../]
  [./xdr]
    file_base = T_initial_214
    output_final = true
    type = XDR
  [../]
[]

[ICs]
  [./temperature_ic]
    variable = T
    type = FunctionIC
    function = -214*y+258.2
  [../]
[]

[PikaMaterials]
  temperature = T
  interface_thickness = 1e-5
  phase = phi
  interface_kinetic_coefficient = 5.5e5
  capillary_length = 1.3e-9
[]

