module GChart
  
  # Renders a burndown chart with bars representing work remaining (todo hours)
  # and a stacked bars representing story points completed or accepted. The
  # data option should be set to a hash keyed by date, the values being a hash
  # containing the keys :todo, :completed and :accepted. For example:
  # 
  #   :data => { '2000-01-01' => {:todo => 10, :completed => 2, :accepted => 1},
  #              '2000-01-02' => {:todo =>  6, :completed => 1, :accepted => 3}}
  #
  # Acceptable options include many of those permitted in GChart::Base:
  #   :data   = {}
  #   :width = 300
  #   :height = 200
  # As well as a special parameter required for the burn down chart, i.e
  #   :plan_estimate_total
  # As a convenience, one my construct a BurnDownChart with an object instead of
  # hash, so long as it responds to #data and #plan_estimate_total methods.
  class BurnDownChart < Base
    
    attr_accessor :plan_estimate_total
    
    def initialize(*args, &block)
      unless args.first.kind_of?( Hash )
        o = hash_val_adaptor( args.first )
        args = [o.hash_val( :data, :plan_estimate_total )]
      end
      super( *args, &block )
      @colors = ["026cfd","76c10f", "f5d100"]
    end
    
    
    def hash_val_adaptor( o )
      class << o
        def hash_val( *keys )
          h = {}
          keys.each do |key|
            h.store( key, self.send(key) ) if self.respond_to?( key )
          end
          return h
        end
      end
      return o
    end

    def render_chart_type #:nodoc:
      "bvs"
    end
    
    def enc_set(data, max)
      non_zero_max = (max != 0.0) ? max : 1.0                           
      data.map{|n| GChart.encode(:text, n, non_zero_max )}.join(',')
    end
    
    # Take a hash keyed by a String date and re-key with a Date object.    
    def parse_date_keys( hash )
      new_hash = {}
      hash.each_pair do |key,value|
        case key
        when String
          date = Date.parse( key )
        when Date
          date = key
        end
        new_hash.store( date , value)
      end
      return new_hash
    end
  
    def render_data(params) #:nodoc:
      
      todo, completed, accepted =  [], [], []
      
      # fix the dates so we are working
      # with real date objects instead of Stings.
      clean_data = parse_date_keys( data )
      
      sorted_keys = clean_data.keys.sort
      sorted_keys.each do |k|
        # interleve array because GoogleCharts does not support both groups 
        # and stacked bars at once. For each day we have two bars, the first 
        # is for TODO hours and the second is a the stack of points complete 
        # and accepted. 
        todo                << clean_data[k][:todo].to_f  << 0.0
        completed << 0.0    << clean_data[k][:completed].to_f
        accepted  << 0.0    << clean_data[k][:accepted].to_f          
      end
      
      # compute max for each scale, todo (hours) and accepted (days)
      burndn_max = todo.max
      
      # max of burn up is the plan estimate
      burnup_max = self.plan_estimate_total
      
      # encode the data
      encoded_data = 't:' <<
      enc_set( todo,      burndn_max) << '|' <<
      enc_set( accepted,  burnup_max) << '|' <<
      enc_set( completed, burnup_max)
      
      params["chd"]   = encoded_data
      
      # define axis labels and legend
      
      params['chxt']  = 'y,r' 
      params['chxr']  = "0,0,#{burndn_max}|1,0,#{burnup_max}"   # y1,y2 ranges
      params['chbh']  = 'r,0.2,0.2'
      
      #date_labels = sorted_keys.map{|d| "#{d.mon}/#{d.day}"}      
      #params['chxl']  = "0:|" << date_labels.join('||') << '||' # x, dates
      #params['chdl']  = 'TODO|Accepted|Completed'               # legend
      
    end
  end
  
end

# Allow symbols to be sorted
class Symbol
  include Comparable
  def <=>( obj )
    self.to_s <=> obj.to_s    
  end
end

