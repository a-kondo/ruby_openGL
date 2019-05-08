require "glut"
require "glu"
require "gl"

module Color
  BLACK = [0.0, 0.0, 0.0] 
  WHITE = [1.0, 1.0, 1.0]
  RED = [1.0, 0.0, 0.0]
  GREEN = [0.0, 1.0, 0.0]
  BLUE = [0.0, 0.0, 1.0]
end

class Point
  attr_reader :x
  attr_reader :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Link
  attr_reader :start_node, :end_node
  attr_accessor :line_color, :node_color
  @@node_size = 5

  def draw
    GL.PointSize(@@node_size)
    GL.Begin(GL::POINTS)
    GL.Color3dv(@node_color)
    GL.Vertex3fv(@start_node)
    GL.Vertex3fv(@end_node)
    GL.End()

    GL.Begin(GL::LINES)
    GL.Color3dv(@line_color)
    GL.Vertex3fv(@start_node)
    GL.Vertex3fv(@end_node)
    GL.End()
  end

  def initialize(start_node, end_node)
    @start_node = start_node
    @end_node = end_node
    @node_color = Color::BLACK
    @line_color = Color::BLACK
  end
end

class Cube
  @@vertex = [
    [0.0, 0.0, 0.0],
    [1.0, 0.0, 0.0],
    [1.0, 1.0, 0.0],
    [0.0, 1.0, 0.0],
    [0.0, 0.0, 1.0],
    [1.0, 0.0, 1.0],
    [1.0, 1.0, 1.0],
    [0.0, 1.0, 1.0]
  ]
  @@edge = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 0],
    [4, 5],
    [5, 6],
    [6, 7],
    [7, 4],
    [0, 4],
    [1, 5],
    [2, 6],
    [3, 7]
  ]

  def self.draw(color)
    GL.Begin(GL::LINES)
    GL.Color3dv(color)
    for i in 0..11
      GL.Vertex3dv(@@vertex[@@edge[i][0]])
      GL.Vertex3dv(@@vertex[@@edge[i][1]])
    end
    GL.End()
  end
end

class Map
  attr_reader :db_path

  def initialize(file_path)
    @db_path = file_path
    sql = "SELECT MIN_LATITUDE, MIN_LONGITUDE, MAX_LATITUDE, MAX_LONGITUDE from METADATA"
    ret = `sqlite3 #{@db_path} "#{sql}"`
    min_lat, min_lng, max_lat, max_lng = ret.chop!.split('|')
    puts "border"
    @min_lat = organize_accuracy_to_i(min_lat)
    @min_lng = organize_accuracy_to_i(min_lng)
    @max_lat = organize_accuracy_to_i(max_lat)
    @max_lng = organize_accuracy_to_i(max_lng)
    puts "min: #{@min_lat} #{@min_lng}"
    puts "----------"


    sql = "SELECT LATITUDE from node order by LATITUDE limit 1"
    ret = `sqlite3 #{@db_path} "#{sql}"`
    @min_lat2 = organize_accuracy_to_i(ret.chop)

    sql = "SELECT LONGITUDE from node order by LONGITUDE limit 1"
    ret = `sqlite3 #{@db_path} "#{sql}"`
    @min_lng2 = organize_accuracy_to_i(ret.chop)

    puts "min ___ #{@min_lat2} #{@min_lng2}"

    @links = []
  end

  def organize_accuracy_to_i(str)
    i, f = str.split('.')

    for i in 1..7-f.length
      str << '0'
    end

    return str.delete('.').to_i()
  end

  def read()
    # get all node infomation to hash
    sql = "select LATITUDE, LONGITUDE, ID from NODE"
    ret = `sqlite3 #{@db_path} "#{sql}"`
    nodes = ret.split("\n")

    node_hash = {}
    nodes.each do |node|
      lat, lng, id = node.split('|')
      node_hash[id] = {lat: lat, lng: lng}
    end


    sql = "select START_NODE_ID, END_NODE_ID from LINE"
    ret = `sqlite3 #{@db_path} "#{sql}"`
    lines = ret.split("\n")

    lines.each do |line|
      start_node_id, end_node_id = line.split('|')

      # start node 
      s_node_lat = organize_accuracy_to_i(node_hash[start_node_id][:lat])
      s_node_lng = organize_accuracy_to_i(node_hash[start_node_id][:lng])

      lat = s_node_lat - @min_lat2
      lng = s_node_lng - @min_lng2
      # lat /= 17000.0
      # lng /= 107000.0
      lat /= 20000.0
      lng /= 20000.0
      s_point = [lat, lng, 0]

      # end node
      e_node_lat = organize_accuracy_to_i(node_hash[end_node_id][:lat])
      e_node_lng = organize_accuracy_to_i(node_hash[end_node_id][:lng])

      lat = e_node_lat - @min_lat2
      lng = e_node_lng - @min_lng2
      # lat /= 17000.0
      # lng /= 107000.0
      lat /= 20000.0
      lng /= 20000.0
      e_point = [lat, lng, 0]

      #puts "point: #{s_point} #{e_point}"
      @links.push([s_point, e_point])
    end
  end

  def draw()
    @links.each do |link|
      l = Link.new(link[0], link[1])
      l.draw()
    end
  end
end

class Sample 
  def axises
    GL.PointSize(5)
    GL.Begin(GL::POINTS)
    GL.Color3dv(Color::BLACK)
    GL.Vertex3f(0.0, 0.0, 0.0)
    GL.End()

    # blue is x axis
    GL.Begin(GL::LINES)
    GL.Color3dv(Color::BLUE)
    GL.Vertex3f(0.0, 0.0, 0.0)
    GL.Vertex3f(100.0, 0.0, 0.0)
    # red is y axis
    GL.Color3dv(Color::RED)
    GL.Vertex3f(0.0, 0.0, 0.0)
    GL.Vertex3f(0.0, 100.0, 0.0)
    # green is z axis
    GL.Color3dv(Color::GREEN)
    GL.Vertex3f(0.0, 0.0, 0.0)
    GL.Vertex3f(0.0, 0.0, 100.0)
    GL.End()
  end

  def disp()
    GL.Clear(GL::COLOR_BUFFER_BIT)
    GL.LoadIdentity()
    # GLU.LookAt(@view_from_x, @view_from_y, @view_from_z, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
    GLU.LookAt(@view_from_x, @view_from_y, @view_from_z,
               @view_to_x, @view_to_y, @view_to_z, 0.0, 1.0, 0.0)

    axises()

    GL.PushMatrix()
    GL.Rotated(@r, 0.0, 1.0, 0.0)
    Cube.draw(Color::BLACK)

    GL.Translated(1.0, 1.0, 1.0)
    GL.Rotated(@r*2, 0.0, 1.0, 0.0)
    Cube.draw(Color::RED)
    GL.PopMatrix()

    @map.draw()

    GLUT.SwapBuffers()
  end

  def idle()
    @r = 0 if @r >= 360
    @r += 1
    GLUT.PostRedisplay()
  end

  def resize(w, h)
    GL.Viewport(0, 0, w, h)

    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GLU.Perspective(30.0, w/h, 1.0, 300.0)

    GL.MatrixMode(GL::MODELVIEW)
  end

  def mouse(button, state, x, y)
    case button
    when GLUT::LEFT_BUTTON
      if state == GLUT::UP
        if !@points.empty?
          GL.Color3d(0.0, 0.0, 0.0)
          GL.Begin(GL::POLYGON)
          GL.Vertex2d(@points[@points.length-1].x, @points[@points.length-1].y)
          GL.Vertex2d(x, y)
          GL.End()
          GL.Flush()
        end
        point = Point.new(x, y)
        @points.push(point)
      else
        # do nothing
      end
    when GLUT::RIGHT_BUTTON
      puts "right button is pushed #{x} #{y}"
    end
  end

  def motion(x, y)
    puts "in motion #{x} #{y}"
  end

  def keyboard(key, x, y)
    puts "#{key}"
    case key
    when 'q'
      exit()
    
    when 'a'
      if @rotate_flag
        GLUT.IdleFunc(lambda {})
        @rotate_flag = false
      else
        GLUT.IdleFunc(method(:idle).to_proc())
        @rotate_flag = true
      end
    when 'w'
      @r += 1
      GLUT.PostRedisplay()
    
    when 'i'
      view_from_move_to_init()
      print_view_position()
      GLUT.PostRedisplay()
    when 'h'
      @view_from_x -= 2.0
      @view_to_x = @view_from_x
      print_view_position()
      GLUT.PostRedisplay()
    when 'l'
      @view_from_x += 2.0
      @view_to_x = @view_from_x
      print_view_position()
      GLUT.PostRedisplay()
    when 'k'
      @view_from_y += 2.0
      @view_to_y = @view_from_y
      print_view_position()
      GLUT.PostRedisplay()
    when 'j'
      @view_from_y -= 2.0
      @view_to_y = @view_from_y
      print_view_position()
      GLUT.PostRedisplay()
    
    when 's'
      @view_from_z += 10.0
      print_view_position()
      GLUT.PostRedisplay()
    when 'S'
      @view_from_z += 1.0
      print_view_position()
      GLUT.PostRedisplay()
    when 'z'
      @view_from_z -= 10.0
      print_view_position()
      GLUT.PostRedisplay()
    when 'Z'
      @view_from_z -= 1.0
      print_view_position()
      GLUT.PostRedisplay()
    
    when 'H'
      @view_to_x -= 1.0
      print_view_position()
      GLUT.PostRedisplay()
    when 'L'
      @view_to_x += 1.0
      print_view_position()
      GLUT.PostRedisplay()
    when 'K'
      @view_to_y += 1.0
      print_view_position()
      GLUT.PostRedisplay()
    when 'J'
      @view_to_y -= 1.0
      print_view_position()
      GLUT.PostRedisplay()
    when '\033' # ESC but It's not \033, and no print ESC
      exit()
    end
  end

  def view_from_move_to_init()
    @view_from_x = 10.0
    @view_from_y = 10.0
    @view_from_z = 70.0
    @view_to_x = 10.0
    @view_to_y = 10.0
    @view_to_z = 0.0
  end

  def print_view_position()
    puts "view from: #{@view_from_x} #{@view_from_y} #{@view_from_z}"
    puts "       to: #{@view_to_x} #{@view_to_y} #{0}"
  end

  def init()
    @points = []
    @width = 700.0
    @height = 700.0
    @mouse_on_x = 0
    @mouse_on_y = 0
    @r = 0
    @rotate_flag = false
    view_from_move_to_init()
    #--------------
    # temp
    #--------------
    puts "test"
    puts File::open(".config").read()
    @map = Map.new(File::open(".config").read())
    @map.read()

    GLUT.InitWindowPosition(200, 200)
    GLUT.InitWindowSize(@width, @height)
    
    GLUT.Init()
    GLUT.InitDisplayMode(GLUT::RGBA)
    GLUT.CreateWindow("sample window")
    GLUT.DisplayFunc(method(:disp).to_proc())
    GLUT.ReshapeFunc(method(:resize).to_proc())
    GLUT.MouseFunc(method(:mouse).to_proc())
    GLUT.MotionFunc(method(:motion).to_proc())
    GLUT.KeyboardFunc(method(:keyboard).to_proc())
    GL.ClearColor(1.0, 1.0, 1.0, 1.0)
    GLUT.MainLoop()
  end

end

sample = Sample.new
sample.init()