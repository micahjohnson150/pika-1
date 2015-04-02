#ifndef PHASENOSLIPFORCING_H
#define PHASENOSLIPFORCING_H

//Moose Includes
#include "Kernel.h"

//Pika Includes
#include "PropertyUserObjectInterface.h"

// Forward Declarations
class PhaseNoSlipForcing;

template<>
InputParameters validParams<PhaseNoSlipForcing>();

/**
 * Computes a one sided (solid), phase dependent no slip enforcer
 * for continuous media
 */
class PhaseNoSlipForcing : 
    public Kernel//,
 //   public PropertyUserObjectInterface
{
public:
  PhaseNoSlipForcing(const std::string & name, InputParameters parameters);

  virtual ~PhaseNoSlipForcing(){}

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  // Coupled variables
  VariableValue& _phase;
  unsigned _phase_var_number;
  Real _a;
  Real _rho;
};
#endif // PHASENOSLIPFORCING_H
