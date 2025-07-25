#!/bin/bash

# Redis Cache Management Script
# Usage: ./cache-management.sh [command] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
REDIS_HOST=${REDIS_HOST:-"localhost"}
REDIS_PORT=${REDIS_PORT:-"6379"}
REDIS_URL="redis://${REDIS_HOST}:${REDIS_PORT}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Function to check if Redis is accessible
check_redis() {
    if ! redis-cli -h $REDIS_HOST -p $REDIS_PORT ping > /dev/null 2>&1; then
        print_error "Redis is not accessible at $REDIS_HOST:$REDIS_PORT"
        exit 1
    fi
}

# Function to show cache status
show_status() {
    print_header "Redis Cache Status"
    check_redis
    
    print_status "Redis Connection: $REDIS_HOST:$REDIS_PORT"
    
    # Get Redis info
    INFO=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT info)
    
    # Extract key metrics
    USED_MEMORY=$(echo "$INFO" | grep "used_memory_human:" | cut -d: -f2)
    CONNECTED_CLIENTS=$(echo "$INFO" | grep "connected_clients:" | cut -d: -f2)
    TOTAL_COMMANDS=$(echo "$INFO" | grep "total_commands_processed:" | cut -d: -f2)
    KEYS=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT dbsize)
    
    echo "Memory Usage: $USED_MEMORY"
    echo "Connected Clients: $CONNECTED_CLIENTS"
    echo "Total Commands: $TOTAL_COMMANDS"
    echo "Total Keys: $KEYS"
    
    # Show key patterns
    print_status "Key Patterns:"
    redis-cli -h $REDIS_HOST -p $REDIS_PORT --scan --pattern "*" | head -10
}

# Function to flush cache
flush_cache() {
    local pattern=${1:-"*"}
    
    print_header "Flushing Cache"
    check_redis
    
    if [ "$pattern" = "*" ]; then
        print_warning "This will clear ALL cache data!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Cache flush cancelled"
            exit 0
        fi
        
        redis-cli -h $REDIS_HOST -p $REDIS_PORT flushall
        print_status "All cache data cleared"
    else
        print_status "Flushing cache with pattern: $pattern"
        KEYS=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT --scan --pattern "$pattern")
        if [ -n "$KEYS" ]; then
            echo "$KEYS" | xargs redis-cli -h $REDIS_HOST -p $REDIS_PORT del
            print_status "Cache cleared for pattern: $pattern"
        else
            print_status "No keys found matching pattern: $pattern"
        fi
    fi
}

# Function to clear user cache
clear_user_cache() {
    local user_id=$1
    
    if [ -z "$user_id" ]; then
        print_error "User ID is required"
        echo "Usage: $0 clear-user <user_id>"
        exit 1
    fi
    
    print_header "Clearing User Cache"
    check_redis
    
    local user_data_key="user_data:$user_id"
    local user_profile_key="user_profile:$user_id"
    
    redis-cli -h $REDIS_HOST -p $REDIS_PORT del "$user_data_key" "$user_profile_key"
    print_status "Cache cleared for user: $user_id"
    print_status "Cleared keys: $user_data_key, $user_profile_key"
}

# Function to monitor cache in real-time
monitor_cache() {
    print_header "Redis Cache Monitor"
    check_redis
    
    print_status "Monitoring Redis commands (Ctrl+C to stop)..."
    redis-cli -h $REDIS_HOST -p $REDIS_PORT monitor
}

# Function to show cache statistics
show_stats() {
    print_header "Cache Statistics"
    check_redis
    
    # Get detailed Redis info
    INFO=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT info)
    
    echo "=== Memory Statistics ==="
    echo "$INFO" | grep -E "(used_memory|maxmemory|evicted_keys|expired_keys)" | while read line; do
        echo "  $line"
    done
    
    echo ""
    echo "=== Performance Statistics ==="
    echo "$INFO" | grep -E "(total_commands|instantaneous_ops|hit_rate)" | while read line; do
        echo "  $line"
    done
    
    echo ""
    echo "=== Key Statistics ==="
    echo "Total Keys: $(redis-cli -h $REDIS_HOST -p $REDIS_PORT dbsize)"
    
    # Count keys by pattern
    echo "User Data Keys: $(redis-cli -h $REDIS_HOST -p $REDIS_PORT --scan --pattern "user_data:*" | wc -l)"
    echo "User Profile Keys: $(redis-cli -h $REDIS_HOST -p $REDIS_PORT --scan --pattern "user_profile:*" | wc -l)"
}

# Function to show help
show_help() {
    echo "Redis Cache Management Script"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  status              Show cache status and basic info"
    echo "  stats               Show detailed cache statistics"
    echo "  flush [pattern]     Flush cache (default: all keys)"
    echo "  clear-user <id>     Clear cache for specific user"
    echo "  monitor             Monitor Redis commands in real-time"
    echo "  help                Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  REDIS_HOST          Redis host (default: localhost)"
    echo "  REDIS_PORT          Redis port (default: 6379)"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 flush"
    echo "  $0 flush 'user_*'"
    echo "  $0 clear-user 12345"
    echo "  $0 monitor"
}

# Main script logic
case "${1:-help}" in
    "status")
        show_status
        ;;
    "stats")
        show_stats
        ;;
    "flush")
        flush_cache "$2"
        ;;
    "clear-user")
        clear_user_cache "$2"
        ;;
    "monitor")
        monitor_cache
        ;;
    "help"|*)
        show_help
        ;;
esac 