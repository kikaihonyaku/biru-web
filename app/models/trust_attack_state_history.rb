class TrustAttackStateHistory < ActiveRecord::Base
  attr_accessible :month, :attack_state_from, :attack_state_to
  
  belongs_to :attack_state_from, :class_name => 'AttackState'
  belongs_to :attack_state_to, :class_name => 'AttackState'
  
end
