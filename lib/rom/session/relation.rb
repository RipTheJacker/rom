# encoding: utf-8

module ROM
  class Session

    # Adds session-specific functionality on top of ROM's relation.
    #
    # A session relation builds a queue of state changes that will be committed
    # when a session is flushed.
    #
    # @api public
    class Relation
      include Charlatan.new(:relation, kind: ROM::Relation)

      attr_reader :tracker
      private :tracker

      # @api private
      def self.build(relation, tracker)
        mapper = Mapper.build(relation.mapper, tracker)
        new(relation.inject_mapper(mapper), tracker)
      end

      # @api private
      def initialize(relation, tracker)
        super
        @relation, @tracker = relation, tracker
      end

      # Transition an object into a saved state
      #
      # Transient object's state turns into Created
      # Persisted object's state turns into Updated
      #
      # @param [Object] an object to be saved
      #
      # @return [Session::Relation]
      #
      # @api public
      def save(object)
        tracker.queue(state(object).save(relation))
        self
      end

      # Queue an object to be updated
      #
      # @param [Object] object to be updated
      # @param [Hash] new attributes for the update
      #
      # @return [self]
      #
      # @api public
      def update_attributes(object, tuple)
        tracker.queue(state(object).update(relation, tuple))
        self
      end

      # Transient an object into a deleted state
      #
      # @param [Object] an object to be deleted
      #
      # @return [Session::Relation]
      #
      # @api public
      def delete(object)
        tracker.queue(state(object).delete(relation))
        self
      end

      # Return current state of the tracked object
      #
      # @param [Object] an object
      #
      # @return [Session::State]
      #
      # @api public
      def state(object)
        tracker.fetch(identity(object))
      end

      # Return object's identity
      #
      # @param [Object] an object
      #
      # @return [Array]
      #
      # @api public
      def identity(object)
        mapper.identity(object)
      end

      # Start tracking an object within this session
      #
      # @param [Object] an object to be track
      #
      # @return [Session::Relation]
      #
      # @api public
      def track(object)
        tracker.store_transient(object, mapper)
        self
      end

      # Build a new object instance and start tracking
      #
      # @return [Object]
      #
      # @api public
      def new(*args, &block)
        object = mapper.new_object(*args, &block)
        track(object)
        object
      end

      # Check if a tracked object is dirty
      #
      # @param [Object] an object
      #
      # @return [Boolean]
      #
      # @api public
      def dirty?(object)
        state(object).transient? || mapper.dirty?(object)
      end

      # Check if an object is being tracked
      #
      # @param [Object]
      #
      # @return [Boolean]
      #
      # @api public
      def tracking?(object)
        tracker.include?(identity(object))
      end

    end # Relation

  end # Session
end # ROM
