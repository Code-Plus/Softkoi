class InputinputproductPdf < Prawn::Document
  def initialize(inputinputinputproducts_for_pdf,date_from,date_to)
    super()
    @inputinputproducts_for_pdf = inputinputproducts_for_pdf
    @date_from = date_from
    @date_to = date_to
    header
    text_content
    table_content
    footer
  end
  def header
    image "#{Rails.root}/app/assets/images/white_logo.png", :position => 230, :height =>70
  end

  def text_content
    move_down 30
    font("Courier") do
      text "Reporte de productos dados de baja generados desde SOFTKOI APP.", :align => :center
      move_down 30
      text "Este reporte fue generado la fecha: #{Date.today}", :align =>:center
      move_down 40
        text "Productos dados de baja  desde #{@date_from} hasta el #{@date_to}.", :align => :center
    end
  end

  def table_content
    move_down 10
    table inputproduct_rows do
      row(0).font_style = :bold
      self.header = true
      self.row_colors = ['DDDDDD', 'FFFFFF']
      self.column_widths = [40]
      self.position = 80
    end
  end

  def inputproduct_rows
    [['#', 'inputproducto', 'Precio', 'Cantidad de ingreso', 'Fecha']] +
      @inputinputproducts_for_pdf.map do |inputproduct|
      [inputproduct.id,inputproduct.product.name,inputproduct.stock, inputproduct.created_at]
    end
  end

  def footer
    bounding_box [bounds.left, bounds.bottom + 35], :width  => bounds.width  do
      font "Courier"
      stroke_horizontal_rule
      move_down(5)
      number_pages "<page> de <total>", { :start_count_at => 0, :page_filter => :all, :at => [bounds.right - 50, 0], :align => :right, :size => 12 }
      image "#{Rails.root}/app/assets/images/softkoifooter.png", :position => 250, :height =>25
    end
  end
end
