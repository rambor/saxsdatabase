class Ability
  include CanCan::Ability
  
  def initialize(user)
    user ||= User.new # guest user
    if user.role?(:admin)
      can :manage, :all
    else
      can :read, [Experiment]
      can :manage, Submission do |submission|
        submission.try(:user) == user  #limits submissions to only the creator of the submission
      end
      
      cannot [:pending, :active, :destroy_submission], Submission
      
      if user.role?(:author)
        can :create, News 
        can :update, Articles do |article|
          article.try(:user) == user
        end       
      end
      
    end
  end  
end