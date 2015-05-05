class AttackState < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # ランクのスコアの比較。ランクが同じなら0 rank_bの評価の方が低ければ1、rank_bの評価の方が高ければ2を返す
  def self.compare_rank(rank_a, rank_b)
    
    if rank_a.score == rank_b.score
      return 0
    elsif rank_a.score > rank_b.score
      return 1
    else
      return 2
    end
    
  end
end
