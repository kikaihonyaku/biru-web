# -*- encoding:utf-8 *-*
require 'thinreports'
    
class PdfOutputsController < ApplicationController
  def tack_out


    @selected = params[:g1][:selected]
    # @trusts = Trust.joins(:building => :shop ).joins(:owner).joins(:manage_type).where("trusts.id in (?)", @selected)
    #
    # aaa = []
    # @trusts.each do |t|
    #   aaa.push(t.building.name) if t.building
    # end
    
    owner_id_arr = []
    Trust.where("id in (?)", @selected).each do |trust|
      owner_id_arr.push(trust.owner_id)
    end
    
    @owners = Owner.where("id in (?)", owner_id_arr)
    #send_data @owners.to_csv, :filename=>'tack.csv'
    
    # pdfファイルを作成
    #report = ThinReports::Report.create :layout => File.join(Rails.root, 'app/reports', 'pdf_layout.tlf') do |r|
    report = ThinReports::Report.create :layout => File.join(Rails.root, 'app/reports', 'pdf_layout.tlf') do |r|
       
       @owners.each_with_index do |owner, idx|
         
         lbl_num = (idx).modulo(8) # 剰余を求める
         
         if lbl_num == 0
           r.start_new_page
         end
         
         r.page.values "name_0" + (lbl_num + 1).to_s => owner.name
         
       end
       
     end

     send_data report.generate, :filename    => 'foo.pdf', 
                                :type        => 'application/pdf', 
                                :disposition => 'attachment'

  end
  
end
