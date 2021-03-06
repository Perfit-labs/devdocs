module Docs
  class Sphinx
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink', 'hr', '#contents .topic-title', '#topics .topic-title', 'colgroup').remove

        css('.contents > ul:first-child:last-child.simple > li:first-child:last-child').each do |node|
          node.parent.before(node.at_css('> ul')) if node.at_css('> ul')
          node.remove
        end

        css('em.xref', 'tt').each do |node|
          node.name = 'code'
        end

        css('.toc-backref', '.toctree-wrapper', '.contents', 'span.pre', 'pre a > code', 'tbody', 'code > code', 'a > em').each do |node|
          node.before(node.children).remove
        end

        css('div[class*="highlight-"]').each do |node|
          pre = node.at_css('pre')
          pre.content = pre.content
          pre['data-language'] = node['class'][/highlight\-(\w+)/, 1]
          pre['data-language'] = 'php' if pre['data-language'] == 'ci'
          pre['data-language'] = 'markup' if pre['data-language'] == 'html+django'
          pre['data-language'] = 'python' if pre['data-language'] == 'default' || pre['data-language'].start_with?('python')
          node.replace(pre)
        end

        css('span[id]:empty').each do |node|
          (node.next_element || node.previous_element)['id'] ||= node['id'] if node.next_element || node.previous_element
          node.remove
        end

        css('.section').each do |node|
          if node['id']
            if node.first_element_child['id']
              node.element_children[1]['id'] = node['id'] if node.element_children[1]
            else
              node.first_element_child['id'] = node['id']
            end
          end

          node.before(node.children).remove
        end

        css('h2 > a > code').each do |node|
          node.parent.before(node.content).remove
        end

        css('dt').each do |node|
          next unless node['id'] || node.at_css('code')
          links = []
          links << node.children.last.remove while node.children.last.try(:name) == 'a'
          node.inner_html = "<code>#{node.content.strip}</code> "
          links.reverse_each { |link| node << link }
        end

        css('li > p:first-child:last-child').each do |node|
          node.before(node.children).remove
        end

        css('blockquote > div:first-child:last-child').each do |node|
          node.parent.before(node.parent.children).remove
          node.before(node.children).remove
        end

        css('.admonition-example').each do |node|
          title = node.at_css('.admonition-title')
          title.name = 'h4'
          title.remove_attribute 'class'
          node.before(node.children).remove
        end

        css('table[border]').each do |node|
          node.remove_attribute 'border'
          node.remove_attribute 'cellpadding'
          node.remove_attribute 'cellspacing'
        end

        css('code[class]').each do |node|
          node.remove_attribute 'class'
        end

        css('h1').each do |node|
          node.content = node.content
        end

        css('p.rubric').each do |node|
          node.name = 'h4'
        end

        doc
      end
    end
  end
end
