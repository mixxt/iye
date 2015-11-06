module I18nYamlEditor
  class Repository

    attr_reader :store

    def initialize(store)
      @store = store
    end

    def all
      table.map { |k, v| to_entity(v) }
    end

    def exists?(entity)
      ensure_id!(entity)

      table.key?(entity[:id])
    end

    def find(id)
      to_entity(table.fetch(id))
    end

    def create(entity)
      ensure_id!(entity)
      raise "Duplicate key error: #{entity.inspect}" if table.key?(entity[:id])

      _creating(entity) do
        _persisting(entity) do
          table[entity[:id]] = entity.to_h.clone
        end
      end
    end

    def persist(entity)
      ensure_id!(entity)

      _persisting(entity) do
        table[entity[:id]] = table.fetch(entity[:id], {}).merge(entity.to_h)
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

    def _persisting(entity)
      yield
    end

    def ensure_id!(entity)
      raise "id must not be nil on entity #{entity.inspect}" unless entity[:id]
    end

    private

    def table
      @table ||= {}
    end

  end
end