class ReportsController < ApplicationController
    # Provides the main AngularJS-based application
    def index
    end

    # Top URLs for a the last 5 days
    def top_urls
        # TODO: @cache_key should contain some kind of last_modified date for the data set
        @cache_key = "top_urls"

        @logs = Rails.cache.fetch(@cache_key, expires_in: 1.hours) do
          logs = {}
          LogEntry.select(
            Sequel.as(Sequel.function(:date, :created_at), "date"),
            :url,
            Sequel.as(Sequel.function(:count, "*"), :visits)
          ).where(
            "created_at BETWEEN (CURDATE() - INTERVAL 4 DAY) AND (CURDATE() + INTERVAL 4 DAY)"
          ).group(
            Sequel.function(:date, :created_at),
            :url
          ).each do |row|
            key = row[:date]
            logs[key] = [] if logs[key].nil?
            logs[key] << { :url => row[:url], :visits => row[:visits] }
          end
          logs
        end
    end

    # Top 5 referrers for the top 10 URLs groupped by day.
    def top_referrers
        # TODO: @cache_key should contain some kind of last_modified date for the data set
        @cache_key = "top_referrers"

        @logs = Rails.cache.fetch(@cache_key, expires_in: 1.hours) do
            logs = {}
            for i in 0..4 do
                date = Time.at(Time.now - i.days)
                key = date.strftime("%Y-%m-%d")
                logs[key] = []
                LogEntry.select(
                  Sequel.as(Sequel.function(:date, :created_at), "day"),
                  :url,
                  Sequel.as(Sequel.function(:count, "*"), :visits)
                ).where({
                  Sequel.function(:date, :created_at) => Sequel.function(:date, date)
                }).group(
                  Sequel.function(:date, :created_at),
                  :url
                ).order(
                  Sequel.expr(:day).desc,
                  Sequel.expr(:visits).desc
                ).limit(
                  10
                ).each do |row|
                    site = {}
                    site[:url] = row[:url]
                    site[:visits] = row[:visits]
                    site[:referrers] = []

                    # Subquery for the referrers. TODO: Rework the SQL to support including the referrers if possible.
                    LogEntry.select(
                      :url,
                      :referrer,
                      Sequel.as(Sequel.function(:count, "*"), :visits)
                    ).where({
                      Sequel.function(:date, :created_at) => Sequel.function(:date, date),
                      :url => row[:url]
                    }).exclude(
                      :referrer => nil
                    ).group(
                      :referrer,
                      :url
                    ).order(
                      Sequel.expr(:visits).desc
                    ).limit(5).each do |subrow|
                        site[:referrers] << { url: subrow[:referrer], visits: subrow[:visits] }
                    end

                    logs[key] << site
                end
            end

            logs
        end

    end
end
