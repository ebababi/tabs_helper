# = Tabs Helper
module TabsHelper
  class TabBuilder
    attr_reader :tabs

    def initialize(template) #:nodoc:
      @template, @tabs = template, []
    end

    #
    # Creates a tab section, titled by +title+ and linking to +url+, that may
    # optionally define a view scope (provided as a block). The view renders
    # only if the +active+ parameter evaluates to true.
    #
    # The +active+ parameter may be either a boolean value designating that the
    # view scope is active, either a URL string or array of URL strings, that if
    # any of them matches the current URL, evaluate +active+ as true.
    #
    # A tab section that is active renders its optional defined view scope and
    # receive the active class in its HTML markup.
    def tab(title, url, active = nil, &proc)
      active = [active] if active.is_a? ::String
      active = !(active.select { |link| @template.current_page? link }).empty? if active.is_a? ::Array
      active ||= @template.current_page? url

      @tabs << { :title => title, :url => url, :active => active ? 'active' : nil }
      @template.capture(&proc) if block_given? and active
    end
  end

  #
  # Creates a tab series (identified by +name+) and a scope around a specific
  # section of the view. The specified tabs generate the required HTML tags and
  # on the availability of the plugin provided image and stylesheet resources it
  # completes the UI element.
  #
  # The +name+ argument also designates the HTML id attribute of the tab series.
  #
  # Tab series cannot be nest, nevertheless they can be characterized as primary
  # or secondary, and appear alike, by passing <tt>:class => :primary</tt> or
  # <tt>:class => :secondary</tt> in the rightmost argument which is an option
  # hash. The default for a series is to appear as primary.
  #
  # ==== Examples
  # This creates a simple tab series:
  #   <%= tabs_for :tab_series do |t| %>
  #     <%= t.tab 'First Tab', first_tab_path() %>
  #     <%= t.tab 'Second Tab', 'http://example.com/second_tab_path' %>
  #   <% end %>
  #
  # This creates a tab series with scoped views:
  #   <%= tabs_for :search do |t| %>
  #     <%= t.tab 'Simple', search_path(:section => :simple) do %>
  #       <%= form_tag :search do %>
  #         Search for: <%= text_field_tag :query %>
  #       <% end %>
  #     <% end %>
  #     <%= t.tab 'Advanced', search_path(:section => :advanced) do %>
  #       <%= form_tag :search do %>
  #         Search for: <%= text_field_tag :query %>
  #         Search private documents: <%= check_box_tag :private %>
  #       <% end %>
  #     <% end %>
  #   <% end %>
  def tabs_for(name, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.extract_options!

    raise ArgumentError, "Class should be :primary or :secondary" unless [:primary, :secondary].include? klass = options[:class] || :primary

    builder = TabBuilder.new(self)
    content_pane = capture(builder, &proc)

    content_tag(:div, :id => name, :class => 'tabs') do
      content_tag(:ul, :class => "tabs #{klass}") do
        builder.tabs.map do |tab|
          content_tag(:li, :class => tab[:active]) do
            link_to(tab[:url], :title => tab[:title], :class => tab[:active]) do
              content_tag(:span, tab[:title], :class => 'tab')
            end
          end
        end.join("\n").html_safe
      end
    end.concat(content_pane)
  end
end
