<% if name_details[:ledger_item][:underscore_singular] != 'ledger_item' -%>
acts_as_line_item :ledger_item => :<%= name_details[:ledger_item][:underscore_singular] %>
<% else -%>
acts_as_line_item
<% end -%>

belongs_to :<%= name_details[:ledger_item][:underscore_singular] %>, :class_name => '<%= name_details[:ledger_item][:class_name_full] %>'
