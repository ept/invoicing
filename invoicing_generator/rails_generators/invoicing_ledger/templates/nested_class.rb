<%
indent = ''
details[:class_nesting_array].each do |module_name|
    %><%= indent %>module <%= module_name %>
<%
    indent << '  '
end
-%>
<%= indent %>class <%= details[:class_name_base] %><%
unless superclass.blank?
    %> < <%= superclass %><%
end
%>
<%= (inside_template || '').split("\n").map{|line| "#{indent}  #{line}"}.join("\n") %>
<%= indent %>end
<%
details[:class_nesting_array].each do
    indent.sub! '  ', ''
    %><%= indent %>end
<%
end
%>