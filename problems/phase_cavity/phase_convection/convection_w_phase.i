[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmin = -1e-4
  ymin = -1e-4
  xmax = .0051
  ymax = .0051
  elem_type = QUAD9
[]
[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    new_boundary = 99
    coord = '0 0 '
    tolerance = 1e-04
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
[Functions]
  [./phi_func]
    type = SolutionFunction
    from_variable = phi
    solution = uo_initial
  [../]
[]
[Kernels]
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
  [./x_boussinesq]
    type = Boussinesq
    component = 0
    variable = v_x
    T = T
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
  [./y_boussinesq]
    type = Boussinesq
    component = 1
    variable = v_y
    T = T
 [../]

  [./mass_conservation]
    type = INSMass
    variable = p
    v = v_y
    u = v_x
    p = p
  [../]

  [./phase_time]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
    use_temporal_scaling = false
  [../]

  [./phase_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
    use_temporal_scaling = false
  [../]
  [./phase_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]

  [./heat_convection]
    type = PikaConvection
    property = heat_capacity
    use_temporal_scaling = true
    variable = T
    vel_x = v_x
    vel_y = v_y
  [../]

  [./heat_diffusion]
    type = PikaDiffusion
    property = conductivity
    use_temporal_scaling = true
    variable = T
  [../]

  [./vapor_convection]
    type = PikaConvection
    coefficient = 1.0
    use_temporal_scaling = true
    variable = X
    vel_x = v_x
    vel_y = v_y
  [../]
  [./vapor_diffusion]
    type = PikaDiffusion
    property = diffusion_coefficient
    use_temporal_scaling = true
    variable = X
  [../]


[]
[BCs]
#  [./y_no_slip_top]
#    type = DirichletBC
#    variable = v_y
#    boundary = 'left right top bottom'
#    value = 0.0
#  [../]
#  [./x_no_slip_top]
#    type = DirichletBC
#    variable = v_x
#    boundary = 'left right top bottom'
#    value = 0.0
#  [../]

  [./solid_phase_wall]
    type = DirichletBC
    variable = phi
    boundary = 'left right top bottom'
    value = 1
  [../]
  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = 99
    value = 0
 [../]
 [./T_hot]
    type = DirichletBC
    variable = T
    boundary = right
    value = 301.7369208944
 [../]
 [./T_cold]
    type = DirichletBC
    variable = T
    boundary = left
    value = 263.15
 [../]
[]

[UserObjects]
  [./uo_initial]
    type = SolutionUserObject
    execute_on = initial
    mesh = phi_initial_out.e-s004
    timestep = 1
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.001
  end_time = 0.001
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart '
  petsc_options_value = '100 '
  l_max_its = 100
  nl_max_its = 150
  nl_rel_tol = 1e-08
  l_tol = 1e-08
  line_search = none

[]
[Adaptivity]
  max_h_level = 5
  initial_steps = 5
  steps = 0
  marker = phi_marker
  initial_marker = phi_marker
  [./Indicators]
    [./phi_grad_indicator]
      type = GradientJumpIndicator
      variable = phi
    [../]
  [../]
  [./Markers]
    [./phi_marker]
      type = ErrorToleranceMarker
      coarsen = 1e-7
      indicator = phi_grad_indicator
      refine = 1e-5
    [../]
  [../]
[]
[Outputs]
  [./console]
    type = Console
    output_linear = true
    output_nonlinear = true
  [../]
  [./exodus]
    file_base = phase_LDC_h_100
    type = Exodus
    output_final = true
    output_initial = true
  [../]
  [./csv]
    file_base = phase_conv
    type = CSV
  [../]
[]


[PikaMaterials]
  phase = phi
  temperature = 263.15
  interface_thickness = 1e-05
  temporal_scaling = 1e-4
  gravity = '0 -9.81 0'
[]

[ICs]
  [./phase_ic]
    variable = phi
    type = FunctionIC
    function = phi_func
  [../]
  [./T_ic]
    variable = T
    type = FunctionIC
    function =7717.3841788774*x+263.15
  [../]
  [./X_ic]
    variable = X
    type = PikaChemicalPotentialIC
    phase_variable = phi
    variable = X
    temperature = T
  [../]


[]


