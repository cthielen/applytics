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
            $db.fetch("SELECT
                        date(created_at) AS date, url, count(*) AS visits
                       FROM
                        logs
                       WHERE
                        created_at BETWEEN (CURDATE() - INTERVAL 4 DAY) AND (CURDATE() + INTERVAL 4 DAY)
                      GROUP BY
                        date(created_at), url"
                    ) do |row|
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
                $db.fetch("SELECT
                            date(created_at) AS day, url, count(*) AS visits
                        FROM
                            applytics.logs
                        WHERE
                            date(created_at) = date(:date)
                        GROUP BY
                            date(created_at), url ORDER BY day DESC, visits DESC limit 0,10", :date => date) do |row|
                    site = {}
                    site[:url] = row[:url]
                    site[:visits] = row[:visits]
                    site[:referrers] = []

                    # Subquery for the referrers. TODO: Rework the SQL to support including the referrers if possible.
                    $db.fetch("SELECT
                            url, referrer, count(*) AS visits
                        FROM
                            applytics.logs
                        WHERE
                            date(created_at) = '2016-08-01'
                        AND
                            url = 'http://klein.biz/imogene'
                        GROUP BY referrer, url ORDER BY visits DESC limit 0,5") do |subrow|
                        site[:referrers] << { url: subrow[:referrer], visits: subrow[:visits] }
                    end

                    logs[key] << site
                end
            end

            logs
        end

    end
end
