[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 400  
  ny = 200
  xmin = 0
  xmax = 0.04
  ymin = 0
  ymax = 0.02
  elem_type = QUAD9
[]

[MeshModifiers]
  [./pin]
    type = AddExtraNodeset
    coord = '0.005 0.01'
    tolerance = 1e-4
    new_boundary = 99
  [../]
[]

[Variables]
  [./phi]
  [../]
[]

[Kernels]
  [./phi_time_derivative]
    type = PikaTimeDerivative
    variable = phi
    property = relaxation_time
  [../]
  [./phi_diffusion]
    type = PikaDiffusion
    variable = phi
    property = interface_thickness_squared
    temporal_scaling = false
  [../]
  [./phi_double_well]
    type = DoubleWellPotential
    variable = phi
    mob_name = mobility
  [../]
[]
[BCs]
  [./vapor_walls]
    type = DirichletBC
    value = -1
    variable = phi
    boundary = 'top left right bottom'
  [../]

  [./solid_pin]
    type = DirichletBC
    value = 1
    variable = phi
    boundary = 99
  [../]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  dt = 100
  end_time = 1000
  nl_max_its = 20
  solve_type = PJFNK
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = '50 hypre boomeramg'
  nl_rel_tol = 1e-07
  nl_abs_tol = 1e-12
  l_tol = 1e-4
  l_abs_step_tol = 1e-13
[]
[Adaptivity]
  max_h_level = 7
  initial_steps = 7
  steps = 4
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
  print_linear_residuals = true
  print_perf_log = true
  [./out]
    type = Exodus
    file_base = re_20_initial_out
    output_final = true
    output_initial = true
  [../]
[]
[PikaMaterials]
  phase = phi
  temperature = 263.15
  interface_thickness = 1e-06
  temporal_scaling = 1 # 1e-05
  gravity = '0 -9.81 0'
[]

[ICs]
active = 'phase_ic'
  [./phase_ic]
    y1 = 0.01
    variable = phi
    x1 = 0.005
    type = SmoothCircleIC
    int_width = 1e-5
    radius = 0.0005
    outvalue = -1
    invalue = 1
    3D_spheres = false
  [../]
[]

