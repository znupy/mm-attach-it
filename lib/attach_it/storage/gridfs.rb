class Gridfs < Storage

  def initialize
    @grid ||= Mongo::Grid.new(MongoMapper.database)
  end

  def flush_write(image_options = nil)
    image_options.styles.each do |style_name, style_value|
      begin
        filename = style_name.to_s + '_' + image_options.file_name
        filename = image_options.filename(style_name.to_s)
        gridfs_id = @grid.put(transform(style_value, image_options.assigned_file.path).to_blob, :filename => filename, :_id => "#{image_options.object_id}_#{image_options.name}_#{style_name}")
      rescue Exception => exception
        image_options.add_error(exception.to_s)
      end
    end

    begin
      filename = 'original_' + image_options.file_name
      filename = image_options.filename('original')
      gridfs_id = @grid.put(image_options.assigned_file, :filename => filename, :_id => "#{image_options.object_id}_#{image_options.name}_original")
    rescue Exception => exception
      image_options.add_error(exception.to_s)
    end

  end

  def flush_delete(queued_for_delete = nil)
    queued_for_delete.each do |id|
      @grid.delete(id)
    end
  end

  def read(id = nil)    
    @grid.get(id) unless id.nil?
  end

end
