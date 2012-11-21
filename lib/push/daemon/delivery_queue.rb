module Push
  module Daemon
    class DeliveryQueue
      class WakeupError < StandardError;
      end

      def initialize
        @num_notifications = 0
        @queue = []
        @waiting = []
      end


      def push(obj)
        Thread.critical = true
        @queue.push obj
        @num_notifications += 1
        begin
          t = @waiting.shift
          t.wakeup if t
        rescue ThreadError
          retry
        ensure
          Thread.critical = false
        end
        begin
          t.run if t
        rescue ThreadError
        end
      end

      def pop
        while (Thread.critical = true; @queue.empty?)
          @waiting.push Thread.current
          Thread.stop
        end
        @queue.shift
      ensure
        Thread.critical = false
      end

      def wakeup(thread)
        synchronize do
          t = @waiting.delete(thread)
          t.raise WakeupError if t
        end
      end

      def size
        synchronize { @queue.size }
      end

      def notification_processed
        synchronize { @num_notifications -= 1 }
      end

      def notifications_processed?
        synchronize { @num_notifications == 0 }
      end

protected
      def synchronize
        Thread.critical = true
        begin
          yield
        ensure
          Thread.critical = false
        end
      end

    end
  end
end