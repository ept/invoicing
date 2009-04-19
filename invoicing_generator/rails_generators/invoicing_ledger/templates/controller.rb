def index
end

def ledger
  @summaries = <%= name_details[:ledger_item][:class_name_full] %>.account_summaries(params[:id])
  @names = <%= name_details[:ledger_item][:class_name_full] %>.sender_recipient_name_map(params[:id], @summaries.keys)
end

def statement
  # FIXME check if the current user is allowed to access this account statement
  scope = <%= name_details[:ledger_item][:class_name_full] %>.exclude_empty_invoices.sent_or_received_by(params[:id]).sorted(:issue_date)
  @in_effect = scope.in_effect.all
  @open_or_pending = scope.open_or_pending.all
end

def document
  # FIXME check if the current user is allowed to access this ledger item
  @<%= name_details[:ledger_item][:underscore_singular] %> = <%= name_details[:ledger_item][:class_name_full] %>.find(params[:id])
  
  respond_to do |format|
    format.html { render :text => @<%= name_details[:ledger_item][:underscore_singular] %>.render_html, :layout => true }
    format.xml  { render :xml => @<%= name_details[:ledger_item][:underscore_singular] %>.render_ubl }
  end
end
