[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 5
  ny = 10
  xmax = 0.0025
  ymax = 0.005
  elem_type = QUAD9
[]

[Variables]
  [./T]
  [../]
  [./u]
  [../]
  [./phi]
  [../]
  [./v_x]
    order = SECOND
  [../]
  [./p]
  [../]
  [./v_y]
    order = SECOND
  [../]
[]

[AuxVariables]
  [./phi_aux]
  [../]
[]

[Functions]
  [./T_func]
    type = ParsedFunction
    value = -543*y+267.515
  [../]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = phi_initial
  [../]
[]

[Kernels]
  [./heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
  [./heat_time]
    type = PikaTimeDerivative
    variable = T
    property = heat_capacity
    scale = 1.0
  [../]
  [./heat_phi_time]
    type = PikaCoupledTimeDerivative
    variable = T
    property = latent_heat
    scale = -0.5
    use_temporal_scaling = true
    coupled_variable = phi
  [../]
  [./vapor_time]
    type = PikaTimeDerivative
    variable = u
    coefficient = 1.0
    scale = 1.0
  [../]
  [./vapor_diffusion]
    type = PikaDiffusion
    variable = u
    use_temporal_scaling = true
    property = diffusion_coefficient
  [../]
  [./vapor_phi_time]
    type = PikaCoupledTimeDerivative
    variable = u
    coefficient = 0.5
    coupled_variable = phi
    use_temporal_scaling = true
  [../]
  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
    scale = 1.0
  [../]
  [./phi_transition]
    type = PhaseTransition
    variable = phi
    mob_name = mobility
    chemical_potential = u
    coefficient = 1.0
    lambda = phase_field_coupling_constant
  [../]
  [./phi_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./phi_square_gradient]
    type = ACInterface
    variable = phi
    mob_name = mobility
    kappa_name = interface_thickness_squared
  [../]
  [./x_momentum]
    type = PikaMomentum
    variable = v_x
    component = 0
    gravity = '0 -1 0'
    mu = 1
    p = p
    rho = 1
    v = v_y
    phase = phi
    vel_y = v_y
    vel_x = v_x
  [../]
  [./y_momentum]
    type = PikaMomentum
    variable = v_y
    component = 1
    gravity = '0 -1 0'
    mu = 1
    p = p
    rho = 1
    phase = phi
    vel_y = v_y
    vel_x = v_x
  [../]
  [./mass]
    type = INSMass
    variable = p
    p = p
    u = v_x
    v = v_y
  [../]
  [./boussinesq]
    type = PhaseBoussinesq
    variable = v_y
    component = 1
    gravity = '0 -1 0'
    beta = 1
    T = T
    rho = 1
    phase = phi
    T_ref = 263
  [../]
[]

[AuxKernels]
  [./phi_aux_kernel]
    type = PikaPhaseInitializeAux
    variable = phi_aux
    phase = phi
  [../]
[]

[BCs]
  [./T_hot]
    type = DirichletBC
    variable = T
    boundary = bottom
    value = 267.515
  [../]
  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = top
    value = 264.8
  [../]
[]

[Postprocessors]
[]

[UserObjects]
  [./phi_initial]
    type = SolutionUserObject
    mesh = phi_initial_1e5_out.e
    system_variables = phi
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  end_time = 20000
  reset_dt = true
  dtmax = 10
  nl_abs_tol = 1e-12
  nl_rel_tol = 1e-07
  dtmin = 0.1
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 0.1
    percent_change = 1
  [../]
[]

[Adaptivity]
  max_h_level = 5
  marker = combo_marker
  initial_steps = 5
  initial_marker = combo_marker
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
    [./u_grad_indicator]
      type = GradientJumpIndicator
      variable = u
    [../]
  [../]
  [./Markers]
    [./combo_marker]
      type = ComboMarker
      markers = 'phi_grad_marker u_grad_marker'
    [../]
    [./u_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-10
      indicator = u_grad_indicator
      refine = 1e-8
    [../]
    [./phi_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-7
      indicator = phi_grad_indicator
      refine = 1e-5
    [../]
  [../]
[]

[Outputs]
  output_initial = true
  exodus = true
  csv = true
  print_linear_residuals = true
  print_perf_log = true
[]

[ICs]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./temperature_ic]
    variable = T
    type = FunctionIC
    function = T_func
  [../]
  [./vapor_ic]
    variable = u
    type = PikaChemicalPotentialIC
    block = 0
    phase_variable = phi
    temperature = T
  [../]
[]

[PikaMaterials]
  temperature = T
  interface_thickness = 1e-5
  temporal_scaling = 1e-4
  condensation_coefficient = .01
  phase = phi
[]

[PikaCriteriaOutput]
  air_criteria = false
  velocity_criteria = false
  time_criteria = false
  vapor_criteria = false
  chemical_potential = u
  phase = phi
  use_temporal_scaling = true
  ice_criteria = false
  super_saturation = false
  interface_velocity_postprocessors = max
  temperature = T
[]
