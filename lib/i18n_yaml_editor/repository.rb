module I18nYamlEditor
  class Repository

    attr_reader :store

    def initialize(store)
      @store = store
    end

    def all
      table.map { |k, v| to_entity(v) }
    end

    def count
      table.length
    end

    def first
      to_entity(table.first[1])
    end

    def where(condition)
      all.select{ |translation| condition.all?{ |k, v| translation[k] == v } }
    end

    def exists?(entity)
      ensure_id!(entity)

      table.key?(entity[:id])
    end

    def find(id)
      raise "Can't find with nil id" if id.nil?
      to_entity(table.fetch(id))
    end

    def find_or_initialize_by(attributes)
      find_by(attributes) || to_entity(attributes)
    end

    def create(entity)
      ensure_id!(entity)
      raise "Duplicate key error: #{entity.inspect}" if table.key?(entity[:id])

      _creating(entity) do
        _changing(entity) do
          table[entity[:id]] = entity.to_h.clone
        end
      end
    end

    def persist(entity)
      if exists?(entity)
        update(entity)
      else
        create(entity)
      end
    end

    def update(entity)
      ensure_exists!(entity)

      _updating(entity) do
        _changing(entity) do
          table[entity[:id]] = table.fetch(entity[:id], {}).merge(entity.to_h)
        end
      end
    end

    def delete(entity)
      ensure_exists!(entity)

      _deleting(entity) do
        _changing(entity) do
          table.delete(entity[:id])
        end
      end
    end

    def to_entity(attributes)
      entity_class.new(attributes)
    end

    def entity_class
      raise NotImplementedError.new
    end

    private

    def _creating(entity)
      yield
    end

    def _updating(entity)
      yield
    end

    def _deleting(entity)
      yield
    end

    def _changing(entity)
      yield
    end

    def ensure_id!(entity)
      raise "id must not be nil on entity #{entity.inspect}" unless entity[:id]
    end

    def ensure_exists!(entity)
      ensure_id!(entity)
      raise "given entity does not exist in repository. #{entity.inspect}" unless table.key?(entity.id)
    end

    private

    def table
      @table ||= {}
    end

  end
end