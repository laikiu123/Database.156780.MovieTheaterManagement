-- ================================================
-- 1. TẠO BẢNG Movie
-- Lưu thông tin về phim/sự kiện
-- ================================================
CREATE TABLE Movie (
    movie_id          INT IDENTITY(1,1) PRIMARY KEY,
        -- Khóa chính tự sinh (1, 2, 3, …)
    title             NVARCHAR(200)    NOT NULL,
        -- Tiêu đề phim, không cho phép NULL
    genre             NVARCHAR(100)    NULL,
        -- Thể loại phim, cho phép NULL nếu chưa phân loại
    duration_minutes  INT              NOT NULL 
        CHECK (duration_minutes > 0),
        -- Thời lượng (phút), bắt buộc >0
    language          NVARCHAR(50)     NULL,
        -- Ngôn ngữ chính của phim
    description       NVARCHAR(MAX)    NULL,
        -- Mô tả dài, có thể để trống
    status            NVARCHAR(20)     NOT NULL 
        CONSTRAINT chk_movie_status 
        CHECK (status IN (N'ĐangChiếu', N'NgừngChiếu')),
        -- Trạng thái hiện tại (đang chiếu hoặc ngừng chiếu)
    poster_url        NVARCHAR(500)    NULL,
        -- Đường dẫn hình bìa phim
    created_at        DATETIME         NOT NULL DEFAULT GETDATE(),
        -- Thời điểm thêm bản ghi
    updated_at        DATETIME         NOT NULL DEFAULT GETDATE()
        -- Thời điểm cập nhật lần cuối (có thể dùng trigger để tự động cập nhật)
);
GO

INSERT INTO Movie
    (title, genre, duration_minutes, language, description, status, poster_url)
VALUES
    (N'The Shawshank Redemption', N'Chính kịch', 142, N'Tiếng Anh',
     N'Một câu chuyện về hy vọng và tình bạn trong nhà tù Shawshank.',
     N'NgừngChiếu', N'https://example.com/posters/shawshank.jpg'),
    (N'The Godfather', N'Tội phạm', 175, N'Tiếng Anh',
     N'Cuộc đời của gia đình mafia Corleone và những âm mưu quyền lực.',
     N'NgừngChiếu', N'https://example.com/posters/godfather.jpg'),
    (N'The Dark Knight', N'Hành động', 152, N'Tiếng Anh',
     N'Batman đối đầu với kẻ ác Joker trong một thành phố hỗn loạn.',
     N'NgừngChiếu', N'https://example.com/posters/dark_knight.jpg'),
    (N'Inception', N'Giả tưởng', 148, N'Tiếng Anh',
     N'Một nhóm chuyên lấy cắp ý tưởng qua giấc mơ kết hợp thực tại.',
     N'NgừngChiếu', N'https://example.com/posters/inception.jpg'),
    (N'Interstellar', N'Khoa học viễn tưởng', 169, N'Tiếng Anh',
     N'Hành trình vũ trụ tìm kiếm hành tinh mới cho nhân loại.',
     N'NgừngChiếu', N'https://example.com/posters/interstellar.jpg'),
    (N'Parasite', N'Tâm lý xã hội', 132, N'Tiếng Hàn Quốc',
     N'Cuộc sống đối lập giữa hai gia đình giàu-nghèo tại Seoul.',
     N'ĐangChiếu', N'https://example.com/posters/parasite.jpg'),
    (N'Avengers: Endgame', N'Hành động', 181, N'Tiếng Anh',
     N'Avengers tập hợp lại để đảo ngược thảm họa do Thanos gây ra.',
     N'ĐangChiếu', N'https://example.com/posters/avengers_endgame.jpg'),
    (N'Titanic', N'Lãng mạn', 195, N'Tiếng Anh',
     N'Câu chuyện tình yêu trên con tàu huyền thoại RMS Titanic.',
     N'NgừngChiếu', N'https://example.com/posters/titanic.jpg'),
    (N'Joker', N'Tâm lý tội phạm', 122, N'Tiếng Anh',
     N'Nguồn gốc và hành trình biến chất của nhân vật Joker.',
     N'ĐangChiếu', N'https://example.com/posters/joker.jpg'),
    (N'Spirited Away', N'Hoạt hình', 125, N'Tiếng Nhật',
     N'Một cô bé lạc vào thế giới linh hồn và tìm đường trở về.',
     N'NgừngChiếu', N'https://example.com/posters/spirited_away.jpg'),
    (N'La La Land', N'Âm nhạc', 128, N'Tiếng Anh',
     N'Chuyện tình lãng mạn giữa nghệ sĩ piano và sao nữ Hollywood.',
     N'ĐangChiếu', N'https://example.com/posters/la_la_land.jpg'),
    (N'Coco', N'Hoạt hình', 105, N'Tiếng Anh',
     N'Chuyến phiêu lưu đến Vùng Đất Linh Hồn của cậu bé Miguel.',
     N'ĐangChiếu', N'https://example.com/posters/coco.jpg'),
    (N'Your Name', N'Romance/Giả tưởng', 106, N'Tiếng Nhật',
     N'Hai bạn trẻ tráo đổi cơ thể và gắn kết qua không gian–thời gian.',
     N'NgừngChiếu', N'https://example.com/posters/your_name.jpg'),
    (N'The Lion King', N'Hoạt hình', 88, N'Tiếng Anh',
     N'Hành trình trưởng thành của sư tử con Simba tại Pride Lands.',
     N'NgừngChiếu', N'https://example.com/posters/lion_king.jpg'),
    (N'Frozen II', N'Hoạt hình', 103, N'Tiếng Anh',
     N'Anna và Elsa cùng bạn bè giải mã bí ẩn vương quốc băng giá.',
     N'ĐangChiếu', N'https://example.com/posters/frozen_2.jpg');
GO

select * from Movie

