[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmax = 0.0025
  ymax = 0.005
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    new_boundary = 99
    coord = '0.0 0.0 '
  [../]
[]
[Variables]
  [./v_x]
    order = SECOND
  [../]
  [./v_y]
    order = SECOND
  [../]
  [./p]
  [../]
  [./phi]
  [../]
  [./T]
  [../]
  [./X]
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
  [./x_momentum_time]
    type = PikaTimeDerivative
    variable = v_x
    coefficient = 1.341
    use_temporal_scaling = false
  [../]
  [./x_momentum]
    type = PikaMomentum
    variable = v_x
    vel_y = v_y
    vel_x = v_x
    component = 0
    p = p
  [../]
  [./x_no_slip]
    type = PhaseNoSlipForcing
    variable = v_x
    phase = phi
    h = 100
  [../]
  [./x_momentum_boussinesq]
    type = Boussinesq
    variable = v_x
    component = 0
    T = T
  [../]

 [./y_momentum_time]
   type = PikaTimeDerivative
   variable = v_y
   coefficient = 1.341
   use_temporal_scaling = false
 [../]

  [./y_momentum]
    type = PikaMomentum
    variable = v_y
    vel_y = v_y
    vel_x = v_x
    component = 1
    p = p
  [../]
  [./y_no_slip]
    type = PhaseNoSlipForcing
    variable = v_y
    phase = phi
    h = 100
  [../]
  [./y_momentum_boussinesq]
    type = Boussinesq
    variable = v_y
    component = 1
    T = T
  [../]
  [./mass_conservation]
    type = INSMass
    variable = p
    u = v_y
    v = v_x
    p = p
  [../]

  [./phi_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
    use_temporal_scaling = false
  [../]
  [./phi_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
    use_temporal_scaling = false
  [../]
  [./phi_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
  [./phi_transition]
    type = PhaseForcing
    variable = phi
    chemical_potential = X
    property = phase_field_coupling_constant
    use_temporal_scaling = false
  [../]

 [./Heat_time]
   type = PikaTimeDerivative
   variable = T
   property = heat_capacity
 [../]
   [./Heat_convection]
    type = PikaConvection
    variable = T
    vel_x = v_x
    use_temporal_scaling = false
    property = heat_capacity
    vel_y = v_y
  [../]
  [./Heat_diffusion]
    type = PikaDiffusion
    variable = T
    use_temporal_scaling = true
    property = conductivity
  [../]
  [./Heat_phi_time]
    type = PikaCoupledTimeDerivative
    variable = T
    use_temporal_scaling = true
    property = latent_heat
    coupled_variable = phi
    scale = -0.5
  [../]
 [./Vapor_time]
   type = PikaTimeDerivative
   variable = X
   coefficient = 1.0
   use_temporal_scaling = false
 [../] 
   [./Vapor_convection]
    type = PikaPhaseConvection
    variable = X
    vel_x = v_x
    use_temporal_scaling = false
    phase = phi
    coefficient = 1.0
    vel_y = v_y
  [../]
  [./Vapor_diffusion]
    type = PikaDiffusion
    variable = X
    use_temporal_scaling = true
    property = diffusion_coefficient
  [../]
  [./Vapor_phi_time]
    type = PikaCoupledTimeDerivative
    variable = X
    use_temporal_scaling = true
    coupled_variable = phi
    coefficient = 1
    scale = 0.5
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
    mesh = phi_initial_1e5_out.e-s009
    system_variables = phi
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.01
  end_time = 1000
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart '
  petsc_options_value = '100 '
  l_max_its = 100
  nl_max_its = 150
  nl_rel_tol = 1e-08
  l_tol = 1e-08
  line_search = none
  scheme = 'crank-nicolson'
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
    [./X_grad_indicator]
      type = GradientJumpIndicator
      variable = X
    [../]
  [../]
  [./Markers]
    [./combo_marker]
      type = ComboMarker
      markers = 'phi_grad_marker X_grad_marker '
    [../]
    [./X_grad_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-10
      indicator = X_grad_indicator
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
    variable = X
    type = PikaChemicalPotentialIC
    block = 0
    phase_variable = phi
    temperature = T
  [../]
[]

[PikaMaterials]
  temperature = T
  interface_thickness = 1e-5
  temporal_scaling = 1
  condensation_coefficient = .01
  phase = phi
  gravity = '0 -9.81 0'
[]

[PikaCriteriaOutput]
  air_criteria = false
  velocity_criteria = false
  time_criteria = false
  vapor_criteria = false
  chemical_potential = X
  phase = phi
  use_temporal_scaling = true
  ice_criteria = false
  super_saturation = false
  interface_velocity_postprocessors = max
  temperature = T
[]

